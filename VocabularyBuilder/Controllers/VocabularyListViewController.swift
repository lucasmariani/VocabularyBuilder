import UIKit
import SwiftData

class VocabularyListViewController: UIViewController {
    private let modelContainer: ModelContainer
    private let ocrServiceManager: OCRServiceManager
    private var words: [VocabularyWord] = []
    private var filteredWords: [VocabularyWord] = []
    private var isSearching = false

    init(modelContainer: ModelContainer, ocrServiceManager: OCRServiceManager) {
        self.modelContainer = modelContainer
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
        searchController.searchBar.placeholder = "Search words..."
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
        titleLabel.text = "No vocabulary words yet"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        titleLabel.textColor = .systemGray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Use the camera to scan book pages and add new words"
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
    }

    private func setupUI() {
        title = "Vocabulary"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController

        view.backgroundColor = .white
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

    private func loadWords() {
        let modelContext = modelContainer.mainContext
        let descriptor = FetchDescriptor<VocabularyWord>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])

        do {
            words = try modelContext.fetch(descriptor)
            DispatchQueue.main.async {
                self.updateFilteredWords()
                self.tableView.reloadData()
                self.updateEmptyState()
            }
        } catch {
            print("Error fetching words: \(error)")
        }
    }

    private func updateFilteredWords() {
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredWords = words.filter { word in
                word.word.localizedCaseInsensitiveContains(searchText) ||
                word.definition.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            filteredWords = words
        }
    }

    private func updateEmptyState() {
        let isEmpty = words.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func deleteWord(at indexPath: IndexPath) {
        let wordToDelete = filteredWords[indexPath.row]
        let modelContext = modelContainer.mainContext

        modelContext.delete(wordToDelete)

        do {
            try modelContext.save()
            loadWords()
        } catch {
            print("Error deleting word: \(error)")
        }
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
        let wordDetailVC = WordDetailViewController(modelContainer: modelContainer, word: word)
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
