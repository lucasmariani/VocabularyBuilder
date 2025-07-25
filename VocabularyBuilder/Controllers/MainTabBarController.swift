//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit
import SwiftData

class MainTabBarController: UITabBarController {
    private let modelContainer: ModelContainer
    private let vocabularyRepository: VocabularyRepository
    private let ocrServiceManager = OCRServiceManager()
    private var vocabularyNavigationController: UINavigationController?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.vocabularyRepository = VocabularyRepository(modelContext: modelContainer.mainContext)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("MainTabBarController viewDidLoad")
        setupTabBar()
        setupViewControllers()
    }

    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = .label
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.label]

        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = .tintColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.tintColor]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        print("Setting up view controllers")

        // Camera Tab
        let cameraViewController = CameraViewController(vocabularyRepository: vocabularyRepository, ocrServiceManager: ocrServiceManager)
        let cameraNavController = UINavigationController(rootViewController: cameraViewController)
        cameraNavController.navigationItem.largeTitleDisplayMode = .never
        cameraNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.scan", comment: "Camera tab title"),
            image: UIImage(systemName: "camera"),
            selectedImage: UIImage(systemName: "camera.fill")
        )

        // Vocabulary Tab
        let vocabularyViewController = VocabularyListViewController(vocabularyRepository: vocabularyRepository, ocrServiceManager: ocrServiceManager)
        let vocabularyNavController = UINavigationController(rootViewController: vocabularyViewController)
        vocabularyNavController.navigationItem.largeTitleDisplayMode = .never
        vocabularyNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.vocabulary", comment: "Vocabulary tab title"),
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        self.vocabularyNavigationController = vocabularyNavController
        
        viewControllers = [cameraNavController, vocabularyNavController]
        print("View controllers set: \(viewControllers?.count ?? 0)")
    }
}

// MARK: - WordSelectionDelegate
extension MainTabBarController: WordSelectionDelegate {
    func wordSelectionDidAddWord(_ word: VocabularyWord) {
        selectedIndex = 1

        guard let vocabularyNavController = vocabularyNavigationController,
              let vocabularyListVC = vocabularyNavController.viewControllers.first as? VocabularyListViewController else {
            return
        }
        vocabularyNavController.popToRootViewController(animated: false)
        vocabularyListVC.navigateToWordDetail(word)
    }
}

