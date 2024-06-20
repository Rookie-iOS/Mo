//
//  AppDelegate.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit
import SnapKit
import AppsFlyerLib
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        AppsFlyerLib.shared().appsFlyerDevKey = "yLppz7VNEnVgPZjoaBjpUi"
        AppsFlyerLib.shared().appleAppID = "6504360704"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataFail(_ error: any Error) {
        MotoLog("\(error)")
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        MotoLog(conversionInfo)
    }
}

