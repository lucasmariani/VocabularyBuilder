import UIKit
import SwiftData

class WordSelectionViewController: UIViewController {
    private let capturedImage: UIImage
    private let ocrResult: OCRResult
    private var dictionaryService = DictionaryService()
    private let modelContainer: ModelContainer

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = ocrResult.recognizedText
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    init(modelContainer: ModelContainer, image: UIImage, ocrResult: OCRResult) {
        self.modelContainer = modelContainer
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
                    handleWordSelection(cleanWord)
                }
            }
        }
    }

    private func handleWordSelection(_ word: String) {
        let alert = UIAlertController(
            title: "Add \"\(word)\" to vocabulary?",
            message: "This will fetch the definition and add it to your vocabulary list.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.addWordToVocabulary(word)
        })

        present(alert, animated: true)
    }

    private func addWordToVocabulary(_ word: String) {
        Task {
            let loadingAlert = UIAlertController(title: "Loading...", message: "Fetching definition", preferredStyle: .alert)
            await MainActor.run {
                present(loadingAlert, animated: true)
            }
            
            do {
                let dictionaryEntry = try await dictionaryService.fetchDefinition(for: word)
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
        let modelContext = modelContainer.mainContext

        let definition = dictionaryEntry.meanings.first?.definitions.first?.definition ?? "No definition available"
        let partOfSpeech = dictionaryEntry.meanings.first?.partOfSpeech

        let vocabularyWord = VocabularyWord(
            word: word,
            definition: definition,
            partOfSpeech: partOfSpeech,
            pronunciation: dictionaryEntry.phonetic
        )

        let context = WordContext(
            sentence: extractSentenceContaining(word: word),
            capturedImageData: capturedImage.jpegData(compressionQuality: 0.7)
        )

        vocabularyWord.contexts.append(context)
        context.vocabularyWord = vocabularyWord

        modelContext.insert(vocabularyWord)

        do {
            try modelContext.save()
        } catch {
            showError("Failed to save word: \(error.localizedDescription)")
            return
        }

        let successAlert = UIAlertController(
            title: "Success!",
            message: "\"\(word)\" has been added to your vocabulary.",
            preferredStyle: .alert
        )

        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })

        present(successAlert, animated: true)
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
