import UIKit
@preconcurrency import Vision
import Foundation

class VisionOCRProvider: OCRProvider {
    let displayName = "iOS Vision"
    let isAvailable = true

    func recognizeText(from image: UIImage) async -> OCRResult? {
        let request = VNRecognizeTextRequest()
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["es-CL"]
        request.recognitionLevel = .accurate

        guard let cgImage = image.cgImage else {
            print("VisionOCR: No CGImage available")
            return nil
        }

        do {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
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
            let cleanedText = fullText.replacingOccurrences(of: "- ", with: "")
            let avgConfidence = observations.isEmpty ? 0.0 : observations.map { $0.confidence }.reduce(0, +) / Float(observations.count)

            let result = OCRResult(
                recognizedText: cleanedText,
                confidence: avgConfidence,
                boundingBox: self.calculateOverallBoundingBox(from: observations),
                textObservations: observations
            )

            return result
        } catch {
            print("VisionOCR: Recognition error - \(error)")
            return nil
        }
    }

    private func calculateOverallBoundingBox(from observations: [RecognizedTextObservation]) -> CGRect {
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
