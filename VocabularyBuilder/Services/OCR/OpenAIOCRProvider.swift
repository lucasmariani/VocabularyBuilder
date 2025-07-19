import UIKit
import Vision

class OpenAIOCRProvider: OCRProviding {
    let displayName = "OpenAI"
    
    private let openAIService = OpenAIService()
    
    var isAvailable: Bool {
        self.openAIService.isAvailable
    }
    
    func recognizeText(from image: UIImage) async -> OCRResult? {
        do {
            let recognizedText = try await self.openAIService.extractTextFromImage(image)

            let result = OCRResult(
                recognizedText: recognizedText,
                confidence: 0.95, // OpenAI generally has high confidence
                boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1),
                textObservations: []
            )
            
            return result
        } catch {
            print("OpenAIOCRProvider error: \(error)")
            return nil
        }
    }
    
    private func createObservationsForText(_ text: String, from image: UIImage) async -> [RecognizedTextObservation] {
        // We'll run a minimal Vision request to get proper observation objects,
        // but we'll use the OpenAI extracted text instead of Vision's results
        guard let cgImage = image.cgImage else { return [] }
        
        var request = RecognizeTextRequest()
        request.recognitionLevel = .fast // Use fast since we're not using the results

        do {
            let handler = ImageRequestHandler(cgImage)
            let results = try await handler.perform(request)

            if !results.isEmpty {
                // Use the first observation as a template but with our OpenAI text
                return [results[0]]
            } else {
                // If no observations, return empty array
                // The word extraction will still work with the full text
                return []
            }
        } catch {
            print("Failed to create template observations: \(error)")
            return []
        }
    }
}
