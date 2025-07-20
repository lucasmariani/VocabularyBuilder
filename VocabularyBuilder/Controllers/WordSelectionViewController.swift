//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import SwiftData

protocol WordSelectionDelegate: AnyObject {
    func wordSelectionDidAddWord(_ word: VocabularyWord)
}

class WordSelectionViewController: UIViewController {
    private let capturedImage: UIImage
    private let ocrResult: OCRResult
    private var dictionaryService = DictionaryService()
    private let vocabularyRepository: VocabularyRepository
    private let textAnalysisService = TextAnalysisService()
    private let textFormattingService = TextFormattingService()
    weak var delegate: WordSelectionDelegate?

    // Store analysis result for later word lookup during selection
    private lazy var textAnalysisResult: TextAnalysisResult = {
        return textAnalysisService.analyzeText(ocrResult.recognizedText)
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()

        // Use stored analysis result for formatting
        let formattedText = textFormattingService.formatText(
            analysisResult: textAnalysisResult,
            configuration: .vocabularyLearning
        )

        textView.attributedText = formattedText
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    init(vocabularyRepository: VocabularyRepository, image: UIImage, ocrResult: OCRResult) {
        self.vocabularyRepository = vocabularyRepository
        self.capturedImage = image
        self.ocrResult = ocrResult
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWordTapping()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Select Word"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupWordTapping() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(_:)))
        textView.addGestureRecognizer(tapGesture)
    }

    @objc private func textViewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: textView)

        if let position = textView.closestPosition(to: location) {
            let range = textView.tokenizer.rangeEnclosingPosition(
                position,
                with: .word,
                inDirection: .layout(.left)
            )

            if let wordRange = range,
               let word = textView.text(in: wordRange)?.trimmingCharacters(in: .whitespacesAndNewlines) {

                let cleanWord = word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

                if !cleanWord.isEmpty {
                    // Convert UITextRange to NSRange for analysis lookup
                    let nsRange = NSRange(
                        location: textView.offset(from: textView.beginningOfDocument, to: wordRange.start),
                        length: textView.offset(from: wordRange.start, to: wordRange.end)
                    )

                    // Lookup word analysis from stored result
                    let wordAnalysis = textAnalysisResult.wordAnalysis(bestMatchingRange: nsRange)

                    let linguisticContext = extractLinguisticContext(around: wordRange)
                    self.handleWordSelection(
                        cleanWord,
                        lexicalClass: wordAnalysis?.lexicalClass,
                        language: wordAnalysis?.language,
                        linguisticContext: linguisticContext
                    )
                }
            }
        }
    }

    private func handleWordSelection(_ word: String, lexicalClass: LexicalClass?, language: Language?, linguisticContext: String?) {
        // Enhance alert message with grammatical info if available
        var message = "This will fetch the definition and add it to your vocabulary list."
        if let lexicalClass = lexicalClass {
            message = "This \(lexicalClass.rawValue.lowercased()) will be added to your vocabulary list."
        }

        let alert = UIAlertController(
            title: "Add \"\(word)\" to vocabulary?",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.addWordToVocabulary(word, lexicalClass: lexicalClass, language: language, linguisticContext: linguisticContext)
        })

        present(alert, animated: true)
    }

    private func addWordToVocabulary(_ word: String, lexicalClass: LexicalClass?, language: Language?, linguisticContext: String?) {
        Task {
            let loadingAlert = UIAlertController(title: "Loading...", message: "Fetching definition", preferredStyle: .alert)
            await MainActor.run {
                present(loadingAlert, animated: true)
            }

            do {
                // Use enhanced dictionary service with lexical class and language context
                let dictionaryEntry = try await dictionaryService.fetchDefinition(
                    for: word,
                    lexicalClass: lexicalClass,
                    language: language,
                    linguisticContext: linguisticContext
                )
                await MainActor.run {
                    loadingAlert.dismiss(animated: true)
                    saveWordToDatabase(word: word, dictionaryEntry: dictionaryEntry)
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true)
                    showError("Could not fetch definition: \(error.localizedDescription)")
                }
            }
        }
    }

    private func saveWordToDatabase(word: String, dictionaryEntry: DictionaryEntry) {
        let definition = dictionaryEntry.meanings.first?.definitions.first?.definition ?? "No definition available"
        let partOfSpeech = dictionaryEntry.meanings.first?.partOfSpeech

        let vocabularyWord = VocabularyWord(
            word: word,
            language: dictionaryEntry.language,
            definition: definition,
            partOfSpeech: partOfSpeech,
        )

        let context = WordContext(
            sentence: extractSentenceContaining(word: word),
            capturedImageData: capturedImage.jpegData(compressionQuality: 0.7)
        )

        vocabularyRepository.addWord(vocabularyWord)
        vocabularyRepository.addContext(context, to: vocabularyWord)

        dismiss(animated: true) { [weak self] in
            self?.delegate?.wordSelectionDidAddWord(vocabularyWord)
        }
    }

    private func extractLinguisticContext(around wordRange: UITextRange) -> String {
        let text = textView.attributedText?.string ?? ""
        let nsRange = NSRange(location: textView.offset(from: textView.beginningOfDocument, to: wordRange.start),
                              length: textView.offset(from: wordRange.start, to: wordRange.end))

        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

        guard let range = Range(nsRange, in: text) else {
            return Array(words.prefix(5)).joined(separator: " ")
        }

        let selectedWord = String(text[range])
        guard let selectedIndex = words.firstIndex(of: selectedWord) else {
            return Array(words.prefix(5)).joined(separator: " ")
        }

        let contextWordsNeeded = 4 // 5 total words minus the selected word
        let wordsBeforeNeeded = min(contextWordsNeeded / 2, selectedIndex)
        let wordsAfterNeeded = min(contextWordsNeeded - wordsBeforeNeeded, words.count - selectedIndex - 1)

        let startIndex = selectedIndex - wordsBeforeNeeded
        let endIndex = selectedIndex + wordsAfterNeeded

        let contextWords = Array(words[startIndex...endIndex])
        return contextWords.joined(separator: " ")
    }

    private func extractSentenceContaining(word: String) -> String {
        let sentences = ocrResult.recognizedText.components(separatedBy: CharacterSet(charactersIn: ".!?"))

        for sentence in sentences {
            if sentence.lowercased().contains(word.lowercased()) {
                return sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return ocrResult.recognizedText
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
