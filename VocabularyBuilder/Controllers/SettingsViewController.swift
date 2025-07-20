//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import Observation

class SettingsViewController: UIViewController {

    private struct Constants {
        static let reuseIdentifier = "SettingsViewController.SettingsCell"
        static let viewTitle = "Settings"

        // Learning Type Section
        static let learningTypeHeaderTitle = "Learning Type"
        static let learningTypeFooterTitle = "Choose your learning approach to optimize the vocabulary building experience"

        // OCR Provider Section
        static let ocrProviderHeaderTitle = "OCR Provider"
        static let ocrProviderFooterTitle = "Choose how to extract text from book page images"
    }

    private let ocrServiceManager: OCRServiceManager
    private let settingsService = SettingsService.shared
    private var sections: [SettingsSection] = []

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
        setupSections()
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

    private func setupSections() {
        // Learning Type Section
        let learningTypeRows = LearningType.allCases.map { learningType in
            SettingsRow(item: learningType) { [weak self] selectedType in
                self?.settingsService.selectLearningType(selectedType)
                self?.tableView.reloadData()
            }
        }

        // OCR Provider Section
        let ocrProviderRows = OCRProviderType.allCases.map { providerType in
            SettingsRow(item: providerType) { [weak self] selectedType in
                self?.settingsService.selectOCRProviderType(selectedType)
                self?.ocrServiceManager.selectedProviderType = selectedType
                self?.tableView.reloadData()
            }
        }

        sections = [
            SettingsSection(
                title: Constants.learningTypeHeaderTitle,
                footerText: Constants.learningTypeFooterTitle,
                rows: learningTypeRows
            ),
            SettingsSection(
                title: Constants.ocrProviderHeaderTitle,
                footerText: Constants.ocrProviderFooterTitle,
                rows: ocrProviderRows
            )
        ]
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.reuseIdentifier)
        let sectionRows = sections[indexPath.section].rows

        if let learningTypeRow = sectionRows[indexPath.row] as? SettingsRow<LearningType> {
            configureCell(cell, with: learningTypeRow.item)
        } else if let ocrProviderRow = sectionRows[indexPath.row] as? SettingsRow<OCRProviderType> {
            configureCell(cell, with: ocrProviderRow.item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerText
    }

    private func configureCell<T: SettingsItem>(_ cell: UITableViewCell, with item: T) {
        cell.selectionStyle = .none
        cell.configurationUpdateHandler = { cell, state in
            var content = UIListContentConfiguration.cell()
            content.text = item.displayName
            content.secondaryText = item.description
            let checkmark = UIImage(systemName: "circle.fill")
            let circle = UIImage(systemName: "circle.dashed")
            content.image = item.isSelected ? checkmark : circle
            cell.contentConfiguration = content
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let sectionRows = sections[indexPath.section].rows

        if let learningTypeRow = sectionRows[indexPath.row] as? SettingsRow<LearningType> {
            learningTypeRow.onSelect(learningTypeRow.item)
        } else if let ocrProviderRow = sectionRows[indexPath.row] as? SettingsRow<OCRProviderType> {
            ocrProviderRow.onSelect(ocrProviderRow.item)
        }
    }
}
