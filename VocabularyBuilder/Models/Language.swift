//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import NaturalLanguage

enum Language: String, CaseIterable {
    // All languages supported by NaturalLanguage framework
    case amharic = "am"
    case arabic = "ar"
    case armenian = "hy"
    case bengali = "bn"
    case bulgarian = "bg"
    case burmese = "my"
    case catalan = "ca"
    case cherokee = "chr"
    case croatian = "hr"
    case czech = "cs"
    case danish = "da"
    case dutch = "nl"
    case english = "en"
    case finnish = "fi"
    case french = "fr"
    case georgian = "ka"
    case german = "de"
    case greek = "el"
    case gujarati = "gu"
    case hebrew = "he"
    case hindi = "hi"
    case hungarian = "hu"
    case icelandic = "is"
    case indonesian = "id"
    case italian = "it"
    case japanese = "ja"
    case kannada = "kn"
    case kazakh = "kk"
    case khmer = "km"
    case korean = "ko"
    case lao = "lo"
    case malay = "ms"
    case malayalam = "ml"
    case marathi = "mr"
    case mongolian = "mn"
    case norwegian = "no"
    case oriya = "or"
    case persian = "fa"
    case polish = "pl"
    case portuguese = "pt"
    case punjabi = "pa"
    case romanian = "ro"
    case russian = "ru"
    case simplifiedChinese = "zh-Hans"
    case sinhalese = "si"
    case slovak = "sk"
    case spanish = "es"
    case swedish = "sv"
    case tamil = "ta"
    case telugu = "te"
    case thai = "th"
    case tibetan = "bo"
    case traditionalChinese = "zh-Hant"
    case turkish = "tr"
    case ukrainian = "uk"
    case urdu = "ur"
    case vietnamese = "vi"

    var englishName: String {
        switch self {
        case .amharic: return "Amharic"
        case .arabic: return "Arabic"
        case .armenian: return "Armenian"
        case .bengali: return "Bengali"
        case .bulgarian: return "Bulgarian"
        case .burmese: return "Burmese"
        case .catalan: return "Catalan"
        case .cherokee: return "Cherokee"
        case .croatian: return "Croatian"
        case .czech: return "Czech"
        case .danish: return "Danish"
        case .dutch: return "Dutch"
        case .english: return "English"
        case .finnish: return "Finnish"
        case .french: return "French"
        case .georgian: return "Georgian"
        case .german: return "German"
        case .greek: return "Greek"
        case .gujarati: return "Gujarati"
        case .hebrew: return "Hebrew"
        case .hindi: return "Hindi"
        case .hungarian: return "Hungarian"
        case .icelandic: return "Icelandic"
        case .indonesian: return "Indonesian"
        case .italian: return "Italian"
        case .japanese: return "Japanese"
        case .kannada: return "Kannada"
        case .kazakh: return "Kazakh"
        case .khmer: return "Khmer"
        case .korean: return "Korean"
        case .lao: return "Lao"
        case .malay: return "Malay"
        case .malayalam: return "Malayalam"
        case .marathi: return "Marathi"
        case .mongolian: return "Mongolian"
        case .norwegian: return "Norwegian"
        case .oriya: return "Oriya"
        case .persian: return "Persian"
        case .polish: return "Polish"
        case .portuguese: return "Portuguese"
        case .punjabi: return "Punjabi"
        case .romanian: return "Romanian"
        case .russian: return "Russian"
        case .simplifiedChinese: return "Simplified Chinese"
        case .sinhalese: return "Sinhalese"
        case .slovak: return "Slovak"
        case .spanish: return "Spanish"
        case .swedish: return "Swedish"
        case .tamil: return "Tamil"
        case .telugu: return "Telugu"
        case .thai: return "Thai"
        case .tibetan: return "Tibetan"
        case .traditionalChinese: return "Traditional Chinese"
        case .turkish: return "Turkish"
        case .ukrainian: return "Ukrainian"
        case .urdu: return "Urdu"
        case .vietnamese: return "Vietnamese"
        }
    }

    /// Initialize from either ISO 639-1 code or NLLanguage raw value
    init?(language: NLLanguage?) {
        // First try direct match
        if let language {
            if let raw = Language(rawValue: language.rawValue) {
                self = raw
                return
            }

            // Handle special cases for Chinese variants
            switch language.rawValue.lowercased() {
            case "zh", "zh-hans":
                self = .simplifiedChinese
            case "zh-hant":
                self = .traditionalChinese
            default:
                // Try to find by iterating through all cases
                if let lang = Language.allCases.first(where: { $0.rawValue == language.rawValue.lowercased() }) {
                    self = lang
                } else {
                    return nil
                }
            }
        }
        return nil
    }
}
