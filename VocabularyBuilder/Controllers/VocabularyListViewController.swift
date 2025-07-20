//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import SwiftData

class VocabularyListViewController: UIViewController {
    private let vocabularyRepository: VocabularyRepository
    private let ocrServiceManager: OCRServiceManager
    private var words: [VocabularyWord] = []
    private var filteredWords: [VocabularyWord] = []
    private var isSearching = false
    private var selectedLanguage: String? = nil

    init(vocabularyRepository: VocabularyRepository, ocrServiceManager: OCRServiceManager) {
        self.vocabularyRepository = vocabularyRepository
        self.ocrServiceManager = ocrServiceManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "Search placeholder text")
        return searchController
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VocabularyTableViewCell.self, forCellReuseIdentifier: VocabularyTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(image: UIImage(systemName: "book.closed"))
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("vocabulary.empty.title", comment: "Empty vocabulary title")
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        titleLabel.textColor = .systemGray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = NSLocalizedString("vocabulary.empty.subtitle", comment: "Empty vocabulary subtitle")
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .systemGray2
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWords()

        // Ensure navigation bar appearance is correct
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barStyle = .default
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = .clear
            navigationBar.barTintColor = .systemBackground
        }
    }

    private func setupUI() {
        title = NSLocalizedString("navigation.vocabulary", comment: "Vocabulary navigation title")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController

        // Add settings button
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        navigationItem.leftBarButtonItem = settingsButton
        self.setupfilterButton()

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])

        updateEmptyState()
    }

    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController(ocrServiceManager: ocrServiceManager)
        let navController = UINavigationController(rootViewController: settingsVC)

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(navController, animated: true)
    }

    private func setupfilterButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            primaryAction: nil,
            menu: self.buildLanguageFilter()
        )
    }

    private func loadWords() {
        words = vocabularyRepository.fetchWords()
        DispatchQueue.main.async {
            self.updateFilteredWords()
            self.tableView.reloadData()
            self.updateEmptyState()
            self.setupfilterButton()
        }
    }

    private func updateFilteredWords() {
        var wordsToFilter = words

        // Apply language filter first
        if let selectedLanguage = selectedLanguage {
            wordsToFilter = wordsToFilter.filter { $0.language == selectedLanguage }
        }

        // Then apply search filter
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredWords = wordsToFilter.filter { word in
                word.word.localizedCaseInsensitiveContains(searchText) ||
                word.definition.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            filteredWords = wordsToFilter
        }
    }

    private func updateEmptyState() {
        let isEmpty = words.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func deleteWord(at indexPath: IndexPath) {
        let wordToDelete = filteredWords[indexPath.row]
        vocabularyRepository.deleteWord(wordToDelete)
        loadWords()
    }

    func navigateToWordDetail(_ word: VocabularyWord) {
        loadWords()

        Task { @MainActor in
            let wordDetailVC = WordDetailViewController(vocabularyRepository: self.vocabularyRepository, word: word)
            self.navigationController?.pushViewController(wordDetailVC, animated: true)
        }
    }

    private func buildLanguageFilter() -> UIMenu {
        let languages = getAvailableLanguages()

        var menuActions: [UIAction] = []

        // Add language options
        for language in languages {
            let languageAction = UIAction(
                title: language,
                image: nil,
                state: self.selectedLanguage == language ? .on : .off
            ) { [weak self] _ in
                self?.selectedLanguage = language
                self?.updateFilteredWords()
                self?.tableView.reloadData()
                self?.setupfilterButton()
            }
            menuActions.append(languageAction)
        }

        // Add "All Languages" option
        let allLanguagesAction = UIAction(
            title: NSLocalizedString("filter.allLanguages", comment: "All languages filter option"),
            image: nil,
            state: self.selectedLanguage == nil ? .on : .off
        ) { [weak self] _ in
            self?.selectedLanguage = nil
            self?.updateFilteredWords()
            self?.tableView.reloadData()
            self?.setupfilterButton()
        }
        menuActions.append(allLanguagesAction)

        return UIMenu(title: NSLocalizedString("filter.byLanguage", comment: "Filter by language menu title"), children: menuActions)
    }

    private func getAvailableLanguages() -> [String] {
        return vocabularyRepository.getAvailableLanguages()
    }
}

// MARK: - UITableViewDataSource
extension VocabularyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VocabularyTableViewCell.identifier, for: indexPath) as? VocabularyTableViewCell else {
            return UITableViewCell()
        }

        let word = filteredWords[indexPath.row]
        cell.configure(with: word)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteWord(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension VocabularyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let word = filteredWords[indexPath.row]
        let wordDetailVC = WordDetailViewController(vocabularyRepository: vocabularyRepository, word: word)
        navigationController?.pushViewController(wordDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - UISearchResultsUpdating
extension VocabularyListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        isSearching = searchController.isActive
        updateFilteredWords()
        tableView.reloadData()
    }
}
