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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor in
                self?.isAuthorized = granted
            }
        }
    }

    func setupCameraSession() -> AVCaptureVideoPreviewLayer? {
        guard isAuthorized else { return nil }

        let session = AVCaptureSession()
        session.beginConfiguration()

        session.sessionPreset = .photo

        guard let selectedDevice = getBestCameraDevice(),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: selectedDevice),
              session.canAddInput(videoDeviceInput) else {
            return nil
        }

        videoDevice = selectedDevice

        session.addInput(videoDeviceInput)

        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else { return nil }

        session.addOutput(photoOutput)
        self.photoOutput = photoOutput

        session.commitConfiguration()
        self.captureSession = session

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = previewLayer

        return previewLayer
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
        guard let captureSession = captureSession else { return }

        if !captureSession.isRunning {
            Task.detached {
                captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        guard let captureSession = captureSession else { return }

        if captureSession.isRunning {
            Task.detached {
                captureSession.stopRunning()
            }
        }
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        isCapturing = true
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .on

        Task.detached { [weak self] in
            guard let self = self else { return }
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
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
                  let image = UIImage(data: imageData) else {
                print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.capturedImage = image
        }
    }
}
