//
//  AppDelegate.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/29/25.
//

import UIKit
import ParseSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Task {
            do {
                try await ParseSwift.initialize(applicationId: "bxTEhV3TpdLJmeHwI3gTqJpdeJkHgTM0tcUfcyCW",
                                                clientKey: "Oe4Hr9XJkWOEJMFOmroj9515dCIdjYV3ncHUUxHY",
                                                serverURL: URL(string: "https://parseapi.back4app.com")!)
                print("ParseSwift initialized")
            } catch {
                // Handle initialization errors
                print("Error initializing ParseSwift: \(error)")
            }
        }
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
                if !hasLaunchedBefore {
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    
                    // 🔹 Remove any cached Parse user
                    Task {
                        do {
                            try await User.logout() // clears session token + cache
                            print("Cleared cached Parse user on first launch.")
                        } catch {
                            print("Error clearing cached user: \(error)")
                        }
                    }
                }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

