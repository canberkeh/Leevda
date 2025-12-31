//
//  FlagService.swift
//  Leevda
//
//  Service for mapping language names to country flags
//

import Foundation

class FlagService {
    static let shared = FlagService()

    private init() {}

    // MARK: - Flag Mapping

    /// Get flag emoji for a language name
    /// Returns country flag or generic globe emoji if not found
    func getFlag(for languageName: String) -> String {
        let normalized = languageName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return languageToFlagMap[normalized] ?? "🌐"
    }

    /// Check if a string is a valid emoji
    func isEmoji(_ string: String) -> Bool {
        guard !string.isEmpty else { return false }

        // Check if string contains emoji
        let scalars = string.unicodeScalars
        return scalars.contains { scalar in
            scalar.properties.isEmoji && scalar.properties.isEmojiPresentation
        }
    }

    /// Get all available language-flag mappings for suggestions
    var availableLanguages: [String] {
        return Array(languageToFlagMap.keys).sorted()
    }

    // MARK: - Language to Flag Mapping

    private let languageToFlagMap: [String: String] = [
        // Major Languages
        "english": "🇬🇧",
        "spanish": "🇪🇸",
        "french": "🇫🇷",
        "german": "🇩🇪",
        "italian": "🇮🇹",
        "portuguese": "🇵🇹",
        "russian": "🇷🇺",
        "chinese": "🇨🇳",
        "japanese": "🇯🇵",
        "korean": "🇰🇷",
        "arabic": "🇸🇦",
        "hindi": "🇮🇳",
        "turkish": "🇹🇷",

        // European Languages
        "dutch": "🇳🇱",
        "polish": "🇵🇱",
        "swedish": "🇸🇪",
        "norwegian": "🇳🇴",
        "danish": "🇩🇰",
        "finnish": "🇫🇮",
        "greek": "🇬🇷",
        "czech": "🇨🇿",
        "hungarian": "🇭🇺",
        "romanian": "🇷🇴",
        "bulgarian": "🇧🇬",
        "croatian": "🇭🇷",
        "serbian": "🇷🇸",
        "ukrainian": "🇺🇦",
        "lithuanian": "🇱🇹",
        "latvian": "🇱🇻",
        "estonian": "🇪🇪",
        "slovenian": "🇸🇮",
        "slovak": "🇸🇰",

        // Asian Languages
        "thai": "🇹🇭",
        "vietnamese": "🇻🇳",
        "indonesian": "🇮🇩",
        "malay": "🇲🇾",
        "tagalog": "🇵🇭",
        "filipino": "🇵🇭",
        "bengali": "🇧🇩",
        "urdu": "🇵🇰",
        "persian": "🇮🇷",
        "farsi": "🇮🇷",
        "hebrew": "🇮🇱",
        "burmese": "🇲🇲",
        "khmer": "🇰🇭",
        "lao": "🇱🇦",
        "mongolian": "🇲🇳",
        "nepali": "🇳🇵",

        // African Languages
        "swahili": "🇰🇪",
        "afrikaans": "🇿🇦",
        "zulu": "🇿🇦",
        "amharic": "🇪🇹",
        "somali": "🇸🇴",
        "hausa": "🇳🇬",
        "yoruba": "🇳🇬",
        "igbo": "🇳🇬",

        // Middle Eastern Languages
        "armenian": "🇦🇲",
        "georgian": "🇬🇪",
        "azerbaijani": "🇦🇿",
        "kazakh": "🇰🇿",
        "uzbek": "🇺🇿",
        "turkmen": "🇹🇲",
        "kyrgyz": "🇰🇬",
        "tajik": "🇹🇯",

        // American Languages
        "portuguese (brazil)": "🇧🇷",
        "brazilian": "🇧🇷",
        "spanish (mexico)": "🇲🇽",
        "mexican": "🇲🇽",
        "spanish (argentina)": "🇦🇷",
        "argentinian": "🇦🇷",

        // Other Regional Variants
        "english (us)": "🇺🇸",
        "english (uk)": "🇬🇧",
        "english (australia)": "🇦🇺",
        "english (canada)": "🇨🇦",
        "french (canada)": "🇨🇦",
        "spanish (spain)": "🇪🇸",
        "portuguese (portugal)": "🇵🇹",
        "chinese (simplified)": "🇨🇳",
        "chinese (traditional)": "🇹🇼",

        // Additional Languages
        "catalan": "🇪🇸",
        "basque": "🇪🇸",
        "galician": "🇪🇸",
        "welsh": "🏴󐁧󐁢󐁷󐁬󐁳󐁿",
        "irish": "🇮🇪",
        "scottish gaelic": "🏴󐁧󐁢󐁳󐁣󐁴󐁿",
        "icelandic": "🇮🇸",
        "maltese": "🇲🇹",
        "luxembourgish": "🇱🇺",
        "albanian": "🇦🇱",
        "macedonian": "🇲🇰",
        "bosnian": "🇧🇦",
        "montenegrin": "🇲🇪",

        // Pacific Languages
        "maori": "🇳🇿",
        "samoan": "🇼🇸",
        "tongan": "🇹🇴",
        "fijian": "🇫🇯",

        // Constructed/Special Languages
        "esperanto": "🌐",
        "latin": "🏛️",
        "sign language": "👋",

        // Programming/Technical (Fun additions)
        "programming": "💻",
        "technical": "⚙️",
        "slang": "🤙",
        "emoji": "😀",
    ]
}
