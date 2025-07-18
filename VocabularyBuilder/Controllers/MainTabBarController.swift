import UIKit
import SwiftData

class MainTabBarController: UITabBarController {
    private let modelContainer: ModelContainer
    private let ocrServiceManager = OCRServiceManager()
    private var vocabularyNavigationController: UINavigationController?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
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
        tabBar.tintColor = .black
    }

    private func setupViewControllers() {
        print("Setting up view controllers")

        // Camera Tab
        let cameraViewController = CameraViewController(modelContainer: modelContainer, ocrServiceManager: ocrServiceManager)
        let cameraNavController = UINavigationController(rootViewController: cameraViewController)
        cameraNavController.navigationItem.largeTitleDisplayMode = .never
        cameraNavController.tabBarItem = UITabBarItem(
            title: "Scan",
            image: UIImage(systemName: "camera"),
            selectedImage: UIImage(systemName: "camera.fill")
        )

        // Vocabulary Tab
        let vocabularyViewController = VocabularyListViewController(modelContainer: modelContainer, ocrServiceManager: ocrServiceManager)
        let vocabularyNavController = UINavigationController(rootViewController: vocabularyViewController)
        vocabularyNavController.navigationItem.largeTitleDisplayMode = .never
        vocabularyNavController.tabBarItem = UITabBarItem(
            title: "Vocabulary",
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

