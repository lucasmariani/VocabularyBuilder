import Foundation
import SwiftData

@Model
final class WordContext {
    var sentence: String = ""
    var capturedImageData: Data?
    var dateAdded = Date()
    
    @Relationship(inverse: \VocabularyWord.contexts) var vocabularyWord: VocabularyWord?
    
    init(sentence: String, capturedImageData: Data? = nil) {
        self.sentence = sentence
        self.capturedImageData = capturedImageData
    }
}
