import Foundation
import SwiftData

@Model
final class WordContext {
    var sentence: String
    var bookTitle: String?
    var pageNumber: Int?
    var capturedImageData: Data?
    var dateAdded: Date
    
    @Relationship(inverse: \VocabularyWord.contexts) var vocabularyWord: VocabularyWord?
    
    init(sentence: String, bookTitle: String? = nil, pageNumber: Int? = nil, capturedImageData: Data? = nil) {
        self.sentence = sentence
        self.bookTitle = bookTitle
        self.pageNumber = pageNumber
        self.capturedImageData = capturedImageData
        self.dateAdded = Date()
    }
}