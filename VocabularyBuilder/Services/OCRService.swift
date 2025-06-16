import UIKit
@preconcurrency import Vision
import Combine

@MainActor
class OCRService: ObservableObject {
    @Published var isProcessing = false
    @Published var recognizedText = ""
    @Published var ocrResult: OCRResult?


    //    func recognizeText(with image: UIImage) async {
    //        guard let cgImage = image.cgImage else {
    //            print("OBS  NO CGIMAGE")
    //            return
    //        }
    //        let req = RecognizeTextRequest()
    //        if let results = try? await req.perform(on: cgImage) {
    //            for observation in results {
    //                observations.append(observation)
    //            }
    //            observations.forEach { obs in
    //                let topCandidate = obs.topCandidates(1).first?.string ?? "no text recognized"
    //                print("OBSERVATIONS")
    //                print("obs: \(topCandidate)")
    //            }
    //        } else {
    //            print("OBS ERROR PERFORMING REQUEST")
    //        }
    //    }

    func recognizeText(from image: UIImage) async -> OCRResult? {
        self.isProcessing = true

        var request = RecognizeTextRequest()
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["es-CL"]
        request.recognitionLevel = .accurate

        guard let cgImage = image.cgImage else {
            print("OBS  NO CGIMAGE")
            return nil
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            let results = request.results ?? []

            var observations = [RecognizedTextObservation]()

            for observation in results {
                observations.append(observation)
            }
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }

            let fullText = recognizedStrings.joined(separator: " ")
            let newFT = fullText.replacingOccurrences(of: "- ", with: "")
            let avgConfidence = observations.isEmpty ? 0.0 : observations.map { $0.confidence }.reduce(0, +) / Float(observations.count)

            let result = OCRResult(
                recognizedText: newFT,
                confidence: avgConfidence,
                boundingBox: self.calculateOverallBoundingBox(from: observations),
                textObservations: observations
            )
            self.recognizedText = newFT
            self.ocrResult = result

            return result
        } catch {
            print("obs request error: \(error)")
            self.isProcessing = false
            return nil
        }

    }

    //    nonisolated func recognizeText(from image: UIImage) -> AnyPublisher<OCRResult, Error> {
    //        return Future<OCRResult, Error> { [weak self] promise in
    //            guard let self = self else {
    //                promise(.failure(OCRError.processingFailed))
    //                return
    //            }
    //
    //            Task { @MainActor [weak self] in
    //                self?.isProcessing = true
    //            }
    //
    //            Task { @MainActor [weak self] in
    //                guard let self = self else {
    //                    promise(.failure(OCRError.processingFailed))
    //                    return
    //                }
    //                guard let cgImage = image.cgImage else {
    //                    Task { @MainActor [weak self] in
    //                        self?.isProcessing = false
    //                    }
    //                    promise(.failure(OCRError.invalidImage))
    //                    return
    //                }
    //
    //                let request = RecognizeTextRequest()
    //                if let results = try? await request.perform(on: cgImage) {
    //
    //                    var observations = [RecognizedTextObservation]()
    //
    //                    for observation in results {
    //                        observations.append(observation)
    //                    }
    //                    let recognizedStrings = observations.compactMap { observation in
    //                        return observation.topCandidates(1).first?.string
    //                    }
    //
    //                    let fullText = recognizedStrings.joined(separator: "\n")
    //                    let avgConfidence = observations.isEmpty ? 0.0 : observations.map { $0.confidence }.reduce(0, +) / Float(observations.count)
    //
    //                    let result = OCRResult(
    //                        recognizedText: fullText,
    //                        confidence: avgConfidence,
    //                        boundingBox: self.calculateOverallBoundingBox(from: observations),
    //                        textObservations: observations
    //                    )
    //
    //                    promise(.success(result))
    //
    //                    Task { @MainActor [weak self] in
    //                        self?.recognizedText = fullText
    //                        self?.ocrResult = result
    //                    }
    //                } else {
    //                    promise(.failure(OCRError.processingFailed))
    //                }
    //            }
    //        }
    //        .eraseToAnyPublisher()
    //    }

    nonisolated func extractWordsWithBounds(from result: OCRResult) -> [(word: String, bounds: CGRect)] {
        var wordsWithBounds: [(word: String, bounds: CGRect)] = []

        for observation in result.textObservations {
            guard let candidate = observation.topCandidates(1).first else { continue }

            let words = candidate.string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

            for word in words {
                wordsWithBounds.append((word: word, bounds: observation.boundingBox))
            }
        }

        return wordsWithBounds
    }

    nonisolated private func calculateOverallBoundingBox(from observations: [RecognizedTextObservation]) -> CGRect {
        guard !observations.isEmpty else { return .zero }

        var minX: CGFloat = 1.0
        var minY: CGFloat = 1.0
        var maxX: CGFloat = 0.0
        var maxY: CGFloat = 0.0

        for observation in observations {
            let bounds = observation.boundingBox
            minX = min(minX, bounds.minX)
            minY = min(minY, bounds.minY)
            maxX = max(maxX, bounds.maxX)
            maxY = max(maxY, bounds.maxY)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

enum OCRError: Error, LocalizedError {
    case invalidImage
    case processingFailed
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for OCR processing"
        case .processingFailed:
            return "OCR processing failed"
        case .noTextFound:
            return "No text found in the image"
        }
    }
}
