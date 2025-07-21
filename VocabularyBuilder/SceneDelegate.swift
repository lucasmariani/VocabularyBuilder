import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let modelContainer = appDelegate.sharedModelContainer

        // Create main tab bar controller
        let tabBarController = MainTabBarController(modelContainer: modelContainer)

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

//        if let urlContext = connectionOptions.urlContexts.first {
//            handleWidgetURL(urlContext.url)
//        }
    }

//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        handleWidgetURL(url)
//    }

//    private func handleWidgetURL(_ url: URL) {
//        guard url.scheme == "myapp",
//              url.host == "tab",
//              let tabIndexString = url.pathComponents.last,
//              let tabIndex = Int(tabIndexString) else { return }
//
//        // Switch to the specified tab
//        if let tabBarController = window?.rootViewController as? UITabBarController {
//            tabBarController.selectedIndex = tabIndex
//        }
//    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Check if launched from control
        if let sharedDefaults = UserDefaults(suiteName: "group.com.rianamiCorp.VocabularyBuilder"),
           sharedDefaults.bool(forKey: "launchedFromControl") {

            // Switch to specific tab
            if let tabBar = window?.rootViewController as? UITabBarController {
                tabBar.selectedIndex = 0
            }

            // Reset flag
            sharedDefaults.set(false, forKey: "launchedFromControl")
        }
    }
}
