import UIKit
@preconcurrency import AVFoundation
import Observation

@Observable
@MainActor
class CameraService: NSObject {
    var isAuthorized = false
    var capturedImage: UIImage?
    var isCapturing = false

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var videoDevice: AVCaptureDevice?
    private var previewFrame: CGRect = .zero
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?

    override init() {
        super.init()
        checkCameraPermission()
    }

    private func configureFocusAndMacro() throws {
        guard let videoDevice else {
            return
        }
        try videoDevice.lockForConfiguration()

        // Enable autofocus
        if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
            videoDevice.focusMode = .continuousAutoFocus
        } else if videoDevice.isFocusModeSupported(.autoFocus) {
            videoDevice.focusMode = .autoFocus
        }

        // Set focus point of interest to center
        if videoDevice.isFocusPointOfInterestSupported {
            videoDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        }

        // Enable smooth autofocus if available
        if videoDevice.isSmoothAutoFocusSupported {
            videoDevice.isSmoothAutoFocusEnabled = true
        }

        videoDevice.unlockForConfiguration()
    }

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("🔐 Camera permission status: \(status.rawValue)")

        switch status {
        case .authorized:
            isAuthorized = true
            print("✅ Camera authorized")
        case .notDetermined:
            print("❓ Camera permission not determined, requesting...")
            requestCameraPermission()
        case .denied, .restricted:
            isAuthorized = false
            print("❌ Camera permission denied/restricted")
        @unknown default:
            isAuthorized = false
            print("❌ Unknown camera permission status")
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            print("🔐 Camera permission response: \(granted)")
            Task { @MainActor in
                self?.isAuthorized = granted
                print("🔐 Camera authorization updated to: \(granted)")
            }
        }
    }

    func setupCameraSession() -> AVCaptureVideoPreviewLayer? {
        print("🎥 setupCameraSession called, authorized: \(isAuthorized)")
        guard isAuthorized else {
            print("❌ Not authorized for camera")
            return nil
        }

        // Don't create a new session if one already exists
        if let existingSession = captureSession {
            print("⚠️ Camera session already exists")
            return videoPreviewLayer
        }

        let session = AVCaptureSession()
        session.beginConfiguration()

        // Use photo preset to ensure preview and capture match
        session.sessionPreset = .photo
        print("📸 Session preset set to photo")

        guard let selectedDevice = getBestCameraDevice() else {
            print("❌ No camera device available")
            return nil
        }

        print("📱 Selected camera device: \(selectedDevice.localizedName)")

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: selectedDevice) else {
            print("❌ Failed to create video device input")
            return nil
        }

        guard session.canAddInput(videoDeviceInput) else {
            print("❌ Cannot add video device input to session")
            return nil
        }

        videoDevice = selectedDevice

        session.addInput(videoDeviceInput)

        // Configure focus and macro settings
        try? configureFocusAndMacro()

        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else { return nil }

        // Configure photo output for optimal quality
        if #available(iOS 16.0, *) {
            // maxPhotoDimensions is automatically set to the highest available resolution
            // when the photoOutput is created, so no additional configuration needed
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.addOutput(photoOutput)
        self.photoOutput = photoOutput

        session.commitConfiguration()
        self.captureSession = session

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = previewLayer
        print("🎬 Preview layer created with gravity: \(previewLayer.videoGravity.rawValue)")

        // Initialize rotation coordinator for iOS 17+
        if #available(iOS 17.0, *) {
            self.rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: selectedDevice, previewLayer: previewLayer)
            print("🔄 Rotation coordinator initialized")
        }

        print("✅ Camera session setup complete")
        return self.videoPreviewLayer
    }

    private func getBestCameraDevice() -> AVCaptureDevice? {
        // First try to get the triple camera (supports macro on iPhone 13 Pro and later)
        if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera,
                                                      for: .video,
                                                      position: .back) {
            return tripleCamera
        }

        // Fall back to dual wide camera
        if let dualWideCamera = AVCaptureDevice.default(.builtInDualWideCamera,
                                                        for: .video,
                                                        position: .back) {
            return dualWideCamera
        }

        // Fall back to wide angle camera
        return AVCaptureDevice.default(.builtInWideAngleCamera,
                                       for: .video,
                                       position: .back)
    }

    func startSession() {
        print("▶️ startSession called")
        guard let captureSession = captureSession else {
            print("❌ No capture session to start")
            return
        }

        guard isAuthorized else {
            print("❌ Camera not authorized")
            return
        }

        if !captureSession.isRunning {
            print("🚀 Starting capture session...")
            Task.detached {
                captureSession.startRunning()
                Task { @MainActor in
                    print("✅ Capture session started")
                }
            }
        } else {
            print("⚠️ Capture session already running")
        }
    }

    func stopSession() {
        print("⏹️ stopSession called")
        guard let captureSession = captureSession else {
            print("❌ No capture session to stop")
            return
        }

        if captureSession.isRunning {
            print("🛑 Stopping capture session...")
            Task.detached {
                captureSession.stopRunning()
                Task { @MainActor in
                    print("✅ Capture session stopped")
                }
            }
        } else {
            print("⚠️ Capture session already stopped")
        }
    }

    func updatePreviewFrame(_ frame: CGRect) {
        previewFrame = frame
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        isCapturing = true
        var settings = AVCapturePhotoSettings()

        // Configure for highest quality
        if let photoCodecType = photoOutput.availablePhotoCodecTypes.first {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: photoCodecType])
        }

        settings.flashMode = .on

        // Enable high resolution capture if available
        if #available(iOS 16.0, *) {
            settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        } else {
            settings.isHighResolutionPhotoEnabled = photoOutput.isHighResolutionCaptureEnabled
        }

        // Set photo orientation to match current device orientation
        if let connection = photoOutput.connection(with: .video) {
            if let rotationCoordinator = rotationCoordinator {
                // Use the modern rotation coordinator for proper orientation handling
                connection.videoRotationAngle = rotationCoordinator.videoRotationAngleForHorizonLevelCapture
            }
        }

        Task.detached { [weak self] in
            guard let self = self else { return }
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func resetCaptureImage() {
        capturedImage = nil
    }

    func cleanupSession() {
        print("🧹 Cleaning up camera session")
        stopSession()
        captureSession = nil
        videoPreviewLayer = nil
        photoOutput = nil
        videoDevice = nil
        rotationCoordinator = nil
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            defer {
                self.isCapturing = false
            }
            guard error == nil,
                  let imageData = photo.fileDataRepresentation(),
                  let rawImage = UIImage(data: imageData) else {
                print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.capturedImage = rawImage
        }
    }
}
