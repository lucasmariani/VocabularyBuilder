//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import SwiftData

class WordDetailViewController: UIViewController {
    private let word: VocabularyWord
    private let vocabularyRepository: VocabularyRepository

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var partOfSpeechLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var definitionHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("section.definition", comment: "Definition section header")
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contextHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("section.context", comment: "Context section header")
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contextStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(vocabularyRepository: VocabularyRepository, word: VocabularyWord) {
        self.word = word
        self.vocabularyRepository = vocabularyRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    private func setupUI() {
        title = word.word
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("button.delete", comment: "Delete button"),
            style: .plain,
            target: self,
            action: #selector(deleteButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(wordLabel)
        contentView.addSubview(partOfSpeechLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(definitionHeaderLabel)
        contentView.addSubview(definitionLabel)
        contentView.addSubview(contextHeaderLabel)
        contentView.addSubview(contextStackView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            partOfSpeechLabel.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            partOfSpeechLabel.leadingAnchor.constraint(equalTo: wordLabel.trailingAnchor, constant: 12),
            partOfSpeechLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            partOfSpeechLabel.heightAnchor.constraint(equalToConstant: 28),
            partOfSpeechLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            dateLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            definitionHeaderLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            definitionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            definitionHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            definitionLabel.topAnchor.constraint(equalTo: definitionHeaderLabel.bottomAnchor, constant: 8),
            definitionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            definitionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            contextHeaderLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 24),
            contextHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contextHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            contextStackView.topAnchor.constraint(equalTo: contextHeaderLabel.bottomAnchor, constant: 8),
            contextStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contextStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }

    private func configureContent() {
        wordLabel.text = word.word

        if let partOfSpeech = word.partOfSpeech {
            partOfSpeechLabel.text = " \(partOfSpeech.uppercased()) "
            partOfSpeechLabel.isHidden = false
        } else {
            partOfSpeechLabel.isHidden = true
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateLabel.text = String(format: NSLocalizedString("date.added.format", comment: "Date added format"), dateFormatter.string(from: word.dateAdded))

        definitionLabel.text = "  \(word.definition)  "

        // Configure contexts
        if let contexts = word.contexts {
            if contexts.isEmpty {
                contextHeaderLabel.isHidden = true
                contextStackView.isHidden = true
            } else {
                contextHeaderLabel.isHidden = false
                contextStackView.isHidden = false

                for context in contexts {
                    let contextView = createContextView(for: context)
                    contextStackView.addArrangedSubview(contextView)
                }
            }
        }
    }

    private func createContextView(for context: WordContext) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let sentenceLabel = UILabel()
        sentenceLabel.text = "  \(context.sentence)  "
        sentenceLabel.font = UIFont.systemFont(ofSize: 16)
        sentenceLabel.textColor = .secondaryLabel
        sentenceLabel.numberOfLines = 0
        sentenceLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(sentenceLabel)

        var lastView: UIView = sentenceLabel

        NSLayoutConstraint.activate([
            sentenceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            sentenceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            sentenceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])

        if let imageData = context.capturedImageData, let image = UIImage(data: imageData) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            containerView.addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8),
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                imageView.heightAnchor.constraint(equalToConstant: 150)
            ])

            lastView = imageView
        }

        lastView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12).isActive = true

        return containerView
    }

    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.deleteWord.title", comment: "Delete word alert title"),
            message: String(format: NSLocalizedString("alert.deleteWord.message", comment: "Delete word alert message"), word.word),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("button.cancel", comment: "Cancel button"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("button.delete", comment: "Delete button"), style: .destructive) { [weak self] _ in
            self?.deleteWord()
        })

        present(alert, animated: true)
    }

    private func deleteWord() {
        vocabularyRepository.deleteWord(word)
        navigationController?.popViewController(animated: true)
    }
}
