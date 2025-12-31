//
//  DictionaryAPIService.swift
//  Leevda
//
//  Service for fetching word definitions from Dictionary API
//

import Foundation

// MARK: - Dictionary API Models
struct DictionaryAPIResponse: Codable {
    let word: String
    let phonetics: [Phonetic]?
    let meanings: [Meaning]
}

struct Phonetic: Codable {
    let text: String?
    let audio: String?
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms: [String]?
    let antonyms: [String]?
}

struct Definition: Codable {
    let definition: String
    let example: String?
    let synonyms: [String]?
    let antonyms: [String]?
}

// MARK: - Word Data Result
struct WordData {
    let word: String
    let meaning: String
    let pronunciation: String
    let note: String
}

// MARK: - Dictionary API Service
class DictionaryAPIService {
    static let shared = DictionaryAPIService()

    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    private init() {}

    // MARK: - Fetch Word Definition
    func fetchWordDefinition(word: String) async throws -> WordData {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedWord.isEmpty else {
            throw DictionaryAPIError.emptyWord
        }

        let urlString = baseURL + trimmedWord
        guard let url = URL(string: urlString) else {
            throw DictionaryAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DictionaryAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw DictionaryAPIError.wordNotFound
            }
            throw DictionaryAPIError.serverError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode([DictionaryAPIResponse].self, from: data)

        guard let firstEntry = apiResponse.first else {
            throw DictionaryAPIError.noDataFound
        }

        return parseWordData(from: firstEntry)
    }

    // MARK: - Parse Word Data
    private func parseWordData(from response: DictionaryAPIResponse) -> WordData {
        // Extract pronunciation
        let pronunciation = response.phonetics?.first(where: { $0.text != nil })?.text ?? ""

        // Extract meanings
        var meaningText = ""
        var noteComponents: [String] = []

        for (index, meaning) in response.meanings.enumerated() {
            if index < 3 { // Limit to first 3 meanings
                if let firstDef = meaning.definitions.first {
                    // First meaning goes to the meaning field
                    if meaningText.isEmpty {
                        meaningText = firstDef.definition
                    }

                    // Build note with part of speech, definition, and example
                    var noteSection = "[\(meaning.partOfSpeech.uppercased())] \(firstDef.definition)"

                    if let example = firstDef.example {
                        noteSection += "\nExample: \"\(example)\""
                    }

                    noteComponents.append(noteSection)
                }
            }
        }

        // Add synonyms and antonyms to note
        var additionalInfo: [String] = []

        let allSynonyms = response.meanings.flatMap { $0.synonyms ?? [] }.prefix(5)
        if !allSynonyms.isEmpty {
            additionalInfo.append("Synonyms: \(allSynonyms.joined(separator: ", "))")
        }

        let allAntonyms = response.meanings.flatMap { $0.antonyms ?? [] }.prefix(5)
        if !allAntonyms.isEmpty {
            additionalInfo.append("Antonyms: \(allAntonyms.joined(separator: ", "))")
        }

        if !additionalInfo.isEmpty {
            noteComponents.append("\n" + additionalInfo.joined(separator: "\n"))
        }

        let note = noteComponents.joined(separator: "\n\n")

        return WordData(
            word: response.word,
            meaning: meaningText,
            pronunciation: pronunciation,
            note: note
        )
    }
}

// MARK: - Dictionary API Errors
enum DictionaryAPIError: LocalizedError {
    case emptyWord
    case invalidURL
    case invalidResponse
    case wordNotFound
    case serverError(statusCode: Int)
    case noDataFound

    var errorDescription: String? {
        switch self {
        case .emptyWord:
            return "Please enter a word"
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .wordNotFound:
            return "Word not found in dictionary"
        case .serverError(let code):
            return "Server error (code: \(code))"
        case .noDataFound:
            return "No definition data found"
        }
    }
}
