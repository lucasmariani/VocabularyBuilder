import UIKit
import AVFoundation
import Combine
import SwiftData

class CameraViewController: UIViewController {
    private let modelContainer: ModelContainer
    private let cameraService = CameraService()
    private let ocrService = OCRService()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        //        button.setTitle("Capture", for: .normal)
        //        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        var config = UIButton.Configuration.filled()
        config.title = "Capture"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.buttonSize = .large
        button.configuration = config
        button.configuration = .glass()
        
        //        button.backgroundColor = .systemBlue
        //        button.setTitleColor(.white, for: .normal)
        //        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var permissionLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera permission is required to scan book pages"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
        setupBindings()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.stopSession()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(permissionLabel)
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            permissionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            permissionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            permissionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            permissionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        cameraService.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorized in
                self?.permissionLabel.isHidden = isAuthorized
                self?.captureButton.isHidden = !isAuthorized
            }
            .store(in: &cancellables)
        
        cameraService.$capturedImage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.processCapturedImage(image)
            }
            .store(in: &cancellables)
        
        cameraService.$isCapturing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCapturing in
                self?.captureButton.isEnabled = !isCapturing
                var config = self?.captureButton.configuration
                config?.title = isCapturing ? "Processing..." : "Capture"
                self?.captureButton.configuration = config
            }
            .store(in: &cancellables)
    }
    
    private func setupCamera() {
        guard let previewLayer = cameraService.setupCameraSession() else { return }
        
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    @objc private func captureButtonTapped() {
        cameraService.capturePhoto()
    }
    
    private func processCapturedImage(_ image: UIImage) {
        Task {
            if let result = await ocrService.recognizeText(from: image) {
                self.showWordSelectionView(with: image, ocrResult: result)
            } else {
                print("obs no result")
            }
            
        }
        //        ocrService.recognizeText(from: image)
        //            .receive(on: DispatchQueue.main)
        //            .sink(
        //                receiveCompletion: { completion in
        //                    if case .failure(let error) = completion {
        //                        print("OCR Error: \(error)")
        //                        // Handle error - could show alert
        //                    }
        //                },
        //                receiveValue: { [weak self] result in
        //                    self?.showWordSelectionView(with: image, ocrResult: result)
        //                }
        //            )
        //            .store(in: &cancellables)
    }
    
    private func showWordSelectionView(with image: UIImage, ocrResult: OCRResult) {
        // TODO: the text recognition should happen in the detail view. don't just pass the result.
        let wordSelectionVC = WordSelectionViewController(modelContainer: self.modelContainer, image: image, ocrResult: ocrResult)
        let navController = UINavigationController(rootViewController: wordSelectionVC)
        present(navController, animated: true)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
