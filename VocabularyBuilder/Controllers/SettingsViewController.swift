import UIKit
import Observation

class SettingsViewController: UIViewController {

    private struct Constants {
        static let reuseIdentifier = "SettingsViewController.ProviderCell"
        static let providerDescriptionVision = "Apple's built-in text recognition"
        static let providerDescriptionOpenAI = "AI-powered text extraction via OpenAI"
        static let viewTitle = "Settings"
        static let headerTitle = "OCR Provider"
        static let footerTitle = "Choose how to extract text from book page images"
    }
    private let ocrServiceManager: OCRServiceManager

    private struct ProviderRow {
        let type: OCRProviderType
        let title: String
        let description: String

        init(type: OCRProviderType) {
            self.type = type
            self.title = type.displayName
            switch type {
            case .vision:
                self.description = Constants.providerDescriptionVision
            case .openAI:
                self.description = Constants.providerDescriptionOpenAI
            }
        }
    }

    private let providerRows = OCRProviderType.allCases.map(ProviderRow.init)

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        return tableView
    }()

    init(ocrServiceManager: OCRServiceManager) {
        self.ocrServiceManager = ocrServiceManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = Constants.viewTitle

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        providerRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.reuseIdentifier)
        let providerRow = providerRows[indexPath.row]

        cell.configurationUpdateHandler = { cell, state in
            var content = UIListContentConfiguration.cell()
            content.text = providerRow.title
            content.secondaryText = providerRow.description
            let circle = UIImage(systemName: "circle")
            content.image = self.ocrServiceManager.selectedProviderType == providerRow.type ? .checkmark : circle
            cell.contentConfiguration = content
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Constants.headerTitle
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        Constants.footerTitle
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let selectedProvider = providerRows[indexPath.row]
        ocrServiceManager.selectedProviderType = selectedProvider.type
    }
}
