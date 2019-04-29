//
//  AppDelegate.swift
//


import UIKit
import CarPlay
import Firebase
import SwiftTheme

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CPApplicationDelegate, CPInterfaceControllerDelegate, CPListTemplateDelegate{
    func listTemplate(_ listTemplate: CPListTemplate, didSelect item: CPListItem, completionHandler: @escaping () -> Void) {
        print (item)   //here just for CarPlay to initialize
    }
    
    // MARK: - CarPlay Reference variables
    var carWindow: CPWindow?
    var interfaceController: CPInterfaceController?
    
    // MARK: - Needed to show initial storyboard
    var window: UIWindow?
    
    // MARK: - CPApplicationDelegate methods
    func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        print("[CARPLAY] CONNECTED TO CARPLAY!")
        
        // Keep references to the CPInterfaceController (handles your templates) and the CPMapContentWindow (to draw/load your own ViewController's with a navigation map onto)
        self.interfaceController = interfaceController
        self.carWindow = window
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print ("[CARPLAY] Configuring Firebase")
        }
        
        print(window.description)
        print(interfaceController.description)
        print("[CARPLAY] SETTING CustomNavigationViewController as root VC...")
        window.rootViewController = CustomNavigationViewController()
    }
    
    func application(_ application: UIApplication, didDisconnectCarInterfaceController interfaceController: CPInterfaceController, from window: CPWindow) {
        print("[CARPLAY] DISCONNECTED FROM CARPLAY!")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MyThemes.restoreLastTheme()
        
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent], animated: true)

        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        let titleAttributes = Colors.barTextColors.map { hexString in
            return [
                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.shadow: shadow
            ]
        }

        let navigationBar = UINavigationBar.appearance()
        navigationBar.theme_tintColor = Colors.primaryTextColor
        navigationBar.theme_barTintColor = Colors.primaryColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)

    
        let tabBar = UITabBar.appearance()
        tabBar.theme_tintColor = Colors.accentColor
        tabBar.theme_barTintColor = Colors.secondaryColor

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print ("[App] Configuring Firebase!")
        }        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        MyThemes.saveLastTheme()
    }
}
