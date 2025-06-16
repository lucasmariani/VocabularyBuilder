import UIKit
import AVFoundation
import Observation
import SwiftData

class CameraViewController: UIViewController {
    private let modelContainer: ModelContainer
    private let cameraService = CameraService()
    private let ocrServiceManager: OCRServiceManager
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(modelContainer: ModelContainer, ocrServiceManager: OCRServiceManager) {
        self.modelContainer = modelContainer
        self.ocrServiceManager = ocrServiceManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Capture"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.buttonSize = .large
        button.configuration = config
        button.configuration = .glass()
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
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let newCapturedImage = cameraService.capturedImage,
           !ocrServiceManager.isProcessing {
            processCapturedImage(newCapturedImage)
            cameraService.resetCaptureImage()
        }
        permissionLabel.isHidden = cameraService.isAuthorized
        captureButton.isHidden = !cameraService.isAuthorized

        captureButton.isEnabled = !cameraService.isCapturing
        captureButton.isEnabled = !ocrServiceManager.isProcessing

        var config = captureButton.configuration
        config?.title = (cameraService.isCapturing || ocrServiceManager.isProcessing) ? "Processing..." : "Capture"
        captureButton.configuration = config
    }
    
    @objc private func captureButtonTapped() {
        cameraService.capturePhoto()
    }

    private func processCapturedImage(_ image: UIImage) {
        Task {
            if let result = await ocrServiceManager.recognizeText(from: image) {
                self.showWordSelectionView(with: image, ocrResult: result)
            } else {
                print("OCR: No result from \(ocrServiceManager.selectedProviderType.displayName)")
                // Show error alert
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "OCR Failed",
                        message: "Could not extract text from image using \(ocrServiceManager.selectedProviderType.displayName)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func showWordSelectionView(with image: UIImage, ocrResult: OCRResult) {
        let wordSelectionVC = WordSelectionViewController(modelContainer: self.modelContainer, image: image, ocrResult: ocrResult)
        let navController = UINavigationController(rootViewController: wordSelectionVC)
        present(navController, animated: true)
    }
}
