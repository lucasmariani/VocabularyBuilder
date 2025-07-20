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
    case latvian = "lv"
    case lithuanian = "lt"
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
    case serbian = "sr"
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
        case .amharic: return NSLocalizedString("language.amharic", comment: "Amharic language")
        case .arabic: return NSLocalizedString("language.arabic", comment: "Arabic language")
        case .armenian: return NSLocalizedString("language.armenian", comment: "Armenian language")
        case .bengali: return NSLocalizedString("language.bengali", comment: "Bengali language")
        case .bulgarian: return NSLocalizedString("language.bulgarian", comment: "Bulgarian language")
        case .burmese: return NSLocalizedString("language.burmese", comment: "Burmese language")
        case .catalan: return NSLocalizedString("language.catalan", comment: "Catalan language")
        case .cherokee: return NSLocalizedString("language.cherokee", comment: "Cherokee language")
        case .croatian: return NSLocalizedString("language.croatian", comment: "Croatian language")
        case .czech: return NSLocalizedString("language.czech", comment: "Czech language")
        case .danish: return NSLocalizedString("language.danish", comment: "Danish language")
        case .dutch: return NSLocalizedString("language.dutch", comment: "Dutch language")
        case .english: return NSLocalizedString("language.english", comment: "English language")
        case .finnish: return NSLocalizedString("language.finnish", comment: "Finnish language")
        case .french: return NSLocalizedString("language.french", comment: "French language")
        case .georgian: return NSLocalizedString("language.georgian", comment: "Georgian language")
        case .german: return NSLocalizedString("language.german", comment: "German language")
        case .greek: return NSLocalizedString("language.greek", comment: "Greek language")
        case .gujarati: return NSLocalizedString("language.gujarati", comment: "Gujarati language")
        case .hebrew: return NSLocalizedString("language.hebrew", comment: "Hebrew language")
        case .hindi: return NSLocalizedString("language.hindi", comment: "Hindi language")
        case .hungarian: return NSLocalizedString("language.hungarian", comment: "Hungarian language")
        case .icelandic: return NSLocalizedString("language.icelandic", comment: "Icelandic language")
        case .indonesian: return NSLocalizedString("language.indonesian", comment: "Indonesian language")
        case .italian: return NSLocalizedString("language.italian", comment: "Italian language")
        case .japanese: return NSLocalizedString("language.japanese", comment: "Japanese language")
        case .kannada: return NSLocalizedString("language.kannada", comment: "Kannada language")
        case .kazakh: return NSLocalizedString("language.kazakh", comment: "Kazakh language")
        case .khmer: return NSLocalizedString("language.khmer", comment: "Khmer language")
        case .korean: return NSLocalizedString("language.korean", comment: "Korean language")
        case .lao: return NSLocalizedString("language.lao", comment: "Lao language")
        case .latvian: return NSLocalizedString("language.latvian", comment: "Latvian language")
        case .lithuanian: return NSLocalizedString("language.lithuanian", comment: "Lithuanian language")
        case .malay: return NSLocalizedString("language.malay", comment: "Malay language")
        case .malayalam: return NSLocalizedString("language.malayalam", comment: "Malayalam language")
        case .marathi: return NSLocalizedString("language.marathi", comment: "Marathi language")
        case .mongolian: return NSLocalizedString("language.mongolian", comment: "Mongolian language")
        case .norwegian: return NSLocalizedString("language.norwegian", comment: "Norwegian language")
        case .oriya: return NSLocalizedString("language.oriya", comment: "Oriya language")
        case .persian: return NSLocalizedString("language.persian", comment: "Persian language")
        case .polish: return NSLocalizedString("language.polish", comment: "Polish language")
        case .portuguese: return NSLocalizedString("language.portuguese", comment: "Portuguese language")
        case .punjabi: return NSLocalizedString("language.punjabi", comment: "Punjabi language")
        case .romanian: return NSLocalizedString("language.romanian", comment: "Romanian language")
        case .russian: return NSLocalizedString("language.russian", comment: "Russian language")
        case .serbian: return NSLocalizedString("language.serbian", comment: "Serbian language")
        case .simplifiedChinese: return NSLocalizedString("language.chinese", comment: "Chinese language")
        case .sinhalese: return NSLocalizedString("language.sinhalese", comment: "Sinhalese language")
        case .slovak: return NSLocalizedString("language.slovak", comment: "Slovak language")
        case .spanish: return NSLocalizedString("language.spanish", comment: "Spanish language")
        case .swedish: return NSLocalizedString("language.swedish", comment: "Swedish language")
        case .tamil: return NSLocalizedString("language.tamil", comment: "Tamil language")
        case .telugu: return NSLocalizedString("language.telugu", comment: "Telugu language")
        case .thai: return NSLocalizedString("language.thai", comment: "Thai language")
        case .tibetan: return NSLocalizedString("language.tibetan", comment: "Tibetan language")
        case .traditionalChinese: return NSLocalizedString("language.chinese", comment: "Chinese language")
        case .turkish: return NSLocalizedString("language.turkish", comment: "Turkish language")
        case .ukrainian: return NSLocalizedString("language.ukrainian", comment: "Ukrainian language")
        case .urdu: return NSLocalizedString("language.urdu", comment: "Urdu language")
        case .vietnamese: return NSLocalizedString("language.vietnamese", comment: "Vietnamese language")
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
