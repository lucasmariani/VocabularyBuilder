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
    }
}
