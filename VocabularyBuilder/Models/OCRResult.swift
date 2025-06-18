import Foundation
import Vision

struct OCRResult {
    let recognizedText: String
    let confidence: Float
    let boundingBox: CGRect
    let textObservations: [DocumentObservation]

    init(recognizedText: String, confidence: Float, boundingBox: CGRect, textObservations: [DocumentObservation]) {
        self.recognizedText = recognizedText
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.textObservations = textObservations
    }
}
