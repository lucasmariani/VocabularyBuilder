//
//  VocabularyWord.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation
import SwiftData

@Model
final class VocabularyWord {
    var word: String = ""
    var language: String = ""
    var definition: String = ""
    var partOfSpeech: String?
    var pronunciation: String?
    var dateAdded = Date()
    var masteryLevel: Int = 0
    var studyCount: Int = 0
    
    @Relationship(deleteRule: .cascade) var contexts: [WordContext]? = []
    
    init(word: String, language: String, definition: String, partOfSpeech: String? = nil, pronunciation: String? = nil) {
        self.word = word
        self.language = language
        self.definition = definition
        self.partOfSpeech = partOfSpeech
        self.pronunciation = pronunciation
        self.dateAdded = Date()
    }
}
