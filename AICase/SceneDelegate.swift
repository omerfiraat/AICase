//
//  SceneDelegate.swift
//  CaseAI
//
//  Created by Ömer Fırat
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        
        // Splash screen'i göstermek için SplashViewController'ı kullan
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        self.window = window
        
        window.makeKeyAndVisible()
    }
}
