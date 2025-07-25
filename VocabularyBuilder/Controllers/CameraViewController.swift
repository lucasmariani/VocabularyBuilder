//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import AVFoundation
import Observation
import SwiftData

class CameraViewController: UIViewController {
    private let vocabularyRepository: VocabularyRepository
    private let cameraService = CameraService()
    private let ocrServiceManager: OCRServiceManager
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var previewContainer: UIView?
    private var capturedImageView: UIImageView?
    private var processingOverlay: UIView?
    private var processingLabel: UILabel?
    private var activityIndicator: UIActivityIndicatorView?

    init(vocabularyRepository: VocabularyRepository, ocrServiceManager: OCRServiceManager) {
        self.vocabularyRepository = vocabularyRepository
        self.ocrServiceManager = ocrServiceManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = NSLocalizedString("button.capture", comment: "Capture button title")
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
        label.text = NSLocalizedString("camera.permission.required", comment: "Camera permission message")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft // or .landscape, .all, etc.
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true // Prevents rotation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        print("📱 View did load - camera authorized: \(cameraService.isAuthorized)")
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Try camera setup here after layout is complete
        if cameraService.isAuthorized && previewLayer == nil {
            setupCamera()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfSupportedInterfaceOrientations()
        // Don't start session here - let setupCamera handle it properly
        if previewLayer != nil {
            cameraService.startSession()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.stopSession()
    }

    private func updateUIVisibility() {
        let isAuthorized = cameraService.isAuthorized
        permissionLabel.isHidden = isAuthorized
        captureButton.isHidden = !isAuthorized
        previewContainer?.isHidden = !isAuthorized
    }

    private func setupUI() {
        view.backgroundColor = .black
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

        setupPreviewContainer()
        setupImagePreview()
        setupProcessingOverlay()

    }

    private func setupPreviewContainer() {
        let container = UIView()
        container.backgroundColor = .black
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)
        self.previewContainer = container

        NSLayoutConstraint.activate([
            // Pin to sides with margins
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 4/3),
            container.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20)
        ])

        print("📦 Preview container created with definite constraints")
    }

    private func setupCamera() {
        print("🎥 Setting up camera - isAuthorized: \(cameraService.isAuthorized)")
        guard cameraService.isAuthorized else {
            print("❌ Camera not authorized")
            return
        }

        guard let container = previewContainer, !container.bounds.isEmpty else {
            print("❌ Preview container not ready: \(previewContainer?.bounds ?? .zero)")
            return
        }

        guard let previewLayer = cameraService.setupCameraSession() else {
            print("❌ Failed to setup camera session")
            return
        }

        print("📱 Container bounds: \(container.bounds)")
        previewLayer.frame = container.bounds
        container.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // Update camera service with preview frame
        cameraService.updatePreviewFrame(previewLayer.frame)

        // Start the session now that everything is set up
        cameraService.startSession()
        print("✅ Camera setup complete")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let container = previewContainer else {
            print("❌ No preview container")
            return
        }

        print("📐 Container bounds: \(container.bounds), authorized: \(cameraService.isAuthorized)")

        // Update existing preview layer frame
        if let previewLayer = previewLayer {
            print("🔄 Updating existing preview layer frame")
            previewLayer.frame = container.bounds
            cameraService.updatePreviewFrame(previewLayer.frame)
        }
    }

    override func updateProperties() {
        super.updateProperties()
        if let newCapturedImage = cameraService.capturedImage {
            showCapturedImage(newCapturedImage)
            processCapturedImage(newCapturedImage)
            cameraService.resetCaptureImage()
        }

        let isCapturing = cameraService.isCapturing
        let isProcessing = ocrServiceManager.isProcessing

        updateUIVisibility()

        captureButton.isEnabled = !isCapturing && !isProcessing

        var config = captureButton.configuration
        config?.title = isCapturing ? NSLocalizedString("button.capturing", comment: "Capturing button title") : NSLocalizedString("button.capture", comment: "Capture button title")
        captureButton.configuration = config

        // Show/hide processing overlay
        processingOverlay?.isHidden = !isProcessing
        if isProcessing {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }

        // Update UI visibility based on authorization
        updateUIVisibility()
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
                        title: NSLocalizedString("alert.ocr.failed.title", comment: "OCR failed alert title"),
                        message: String(format: NSLocalizedString("alert.ocr.failed.message", comment: "OCR failed alert message"), ocrServiceManager.selectedProviderType.displayName),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: NSLocalizedString("button.ok", comment: "OK button"), style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func setupImagePreview() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        self.capturedImageView = imageView

        guard let container = previewContainer else { return }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func setupProcessingOverlay() {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.isHidden = true
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = NSLocalizedString("camera.processing", comment: "Processing image label")
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(label)
        overlay.addSubview(indicator)
        view.addSubview(overlay)

        self.processingOverlay = overlay
        self.processingLabel = label
        self.activityIndicator = indicator

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -20),

            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16)
        ])
    }

    private func showCapturedImage(_ image: UIImage) {
        capturedImageView?.image = image
        capturedImageView?.isHidden = false
        previewLayer?.isHidden = true
        cameraService.stopSession()
    }

    private func hideCapturedImage() {
        capturedImageView?.image = nil
        capturedImageView?.isHidden = true
        previewLayer?.isHidden = false
    }

    private func showWordSelectionView(with image: UIImage, ocrResult: OCRResult) {
        let wordSelectionVC = WordSelectionViewController(vocabularyRepository: self.vocabularyRepository, image: image, ocrResult: ocrResult)
        
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            wordSelectionVC.delegate = mainTabBarController
        }

        let navController = UINavigationController(rootViewController: wordSelectionVC)
        present(navController, animated: true) {
            // Reset the camera view after presenting word selection
            self.hideCapturedImage()
            self.cameraService.startSession()
        }
    }
}
