import UIKit
@preconcurrency import Vision
import Foundation

class VisionOCRProvider: OCRProviding {

    struct BookLine {
        var line: String
        var hasSuffix: Bool
    }
    let displayName = "iOS Vision"
    let isAvailable = true

    func recognizeText(from image: UIImage) async -> OCRResult? {

        var request = RecognizeDocumentsRequest()
        request.textRecognitionOptions.automaticallyDetectLanguage = true
        request.textRecognitionOptions.useLanguageCorrection = true
        request.textRecognitionOptions.recognitionLanguages = [Locale.Language(identifier: "en-US"), Locale.Language(identifier: "es-AR")]

        guard let cgImage = image.cgImage else {
            print("VisionOCR: No CGImage available")
            return nil
        }

        do {
            let handler = ImageRequestHandler(cgImage)
            let results = try await handler.perform(request)

            var observations = [DocumentObservation]()
            for observation in results {
                observations.append(observation)
            }

            var lineTranscripts = [BookLine]()
            if let observation = observations.first {
                lineTranscripts = observation.document.paragraphs.flatMap { $0.lines }.map { BookLine(line: $0.transcript, hasSuffix: $0.transcript.hasSuffix("-")) }
            }
            let singleLinesText = mergeSufixedWords(in: lineTranscripts)

            let avgConfidence = observations.isEmpty ? 0.0 : observations.map { $0.confidence }.reduce(0, +) / Float(observations.count)

                        let result = OCRResult(
                            recognizedText: singleLinesText,
                            confidence: avgConfidence,
//                            boundingBox: self.calculateOverallBoundingBox(from: observations),
                            boundingBox: CGRect(),
                            textObservations: observations
                        )

//            let result = OCRResult(
//                recognizedText: singleLinesText,
//                confidence: avgConfidence,
//                boundingBox: CGRect(),
//                textObservations: []
//            )

            return result
        } catch {
            print("VisionOCR: Recognition error - \(error)")
            return nil
        }
    }

    private func mergeSufixedWords(in booklines:[BookLine]) -> String {
        var newArray = [BookLine]()
        var shoudlAmend = false
        for (index, bookLine) in booklines.enumerated() {
            var currentBookLine = bookLine
            if shoudlAmend {
                shoudlAmend.toggle()
                let newLine = bookLine.line.components(separatedBy: " ").dropFirst()
                currentBookLine = BookLine(line: newLine.joined(separator: " "), hasSuffix: bookLine.hasSuffix)
            }

            if currentBookLine.hasSuffix {
                let followupIndex = index + 1
                if booklines.count != followupIndex {
                    if let firstWord = booklines[followupIndex].line.components(separatedBy: " ").first {
                        var lineComponents = currentBookLine.line.components(separatedBy: " ")
                        var lastWord = lineComponents.removeLast()
                        let lastWordMinusHypen = lastWord.dropLast()
                        lastWord = lastWordMinusHypen + firstWord
                        lineComponents.append(lastWord)
                        currentBookLine = BookLine(line: lineComponents.joined(separator: " "), hasSuffix: false)
                        shoudlAmend = true
                    }
                }
            }
            newArray.append(currentBookLine)
        }

        return newArray.map(\.line).joined(separator: "\n")
    }

//    private func calculateOverallBoundingBox(from observations: [DocumentObservation]) -> CGRect {
//        guard !observations.isEmpty else { return .zero }
//
//        var minX: CGFloat = 1.0
//        var minY: CGFloat = 1.0
//        var maxX: CGFloat = 0.0
//        var maxY: CGFloat = 0.0
//
//        for observation in observations {
//            let bounds = observation.document.text.
//            minX = min(minX, bounds.cgRect.minX)
//            minY = min(minY, bounds.cgRect.minY)
//            maxX = max(maxX, bounds.cgRect.maxX)
//            maxY = max(maxY, bounds.cgRect.maxY)
//        }
//
//        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
//    }
}
