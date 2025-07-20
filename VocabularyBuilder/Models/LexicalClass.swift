//
//  LexicalClass.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation

enum LexicalClass: String {
    case noun = "noun"
    case adjective = "adjective"
    case verb = "verb"
    case adverb = "adverb"
    case pronoun = "pronoun"
    case determiner = "determiner"
    case particle = "particle"
    case preposition = "preposition"
    case number = "number"
    case conjunction = "conjunction"
    case interjection = "interjection"
    case classifier = "classifier"
    case idiom = "idiom"
    
    var displayName: String {
        switch self {
        case .noun:
            return NSLocalizedString("lexicalClass.noun", comment: "Noun")
        case .adjective:
            return NSLocalizedString("lexicalClass.adjective", comment: "Adjective")
        case .verb:
            return NSLocalizedString("lexicalClass.verb", comment: "Verb")
        case .adverb:
            return NSLocalizedString("lexicalClass.adverb", comment: "Adverb")
        case .pronoun:
            return NSLocalizedString("lexicalClass.pronoun", comment: "Pronoun")
        case .determiner:
            return NSLocalizedString("lexicalClass.determiner", comment: "Determiner")
        case .particle:
            return NSLocalizedString("lexicalClass.particle", comment: "Particle")
        case .preposition:
            return NSLocalizedString("lexicalClass.preposition", comment: "Preposition")
        case .number:
            return NSLocalizedString("lexicalClass.number", comment: "Number")
        case .conjunction:
            return NSLocalizedString("lexicalClass.conjunction", comment: "Conjunction")
        case .interjection:
            return NSLocalizedString("lexicalClass.interjection", comment: "Interjection")
        case .classifier:
            return NSLocalizedString("lexicalClass.classifier", comment: "Classifier")
        case .idiom:
            return NSLocalizedString("lexicalClass.idiom", comment: "Idiom")
        }
    }
}
