//
//  AppDelegate.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        start()
        return true
    }
    
    // generally it's within a coordinator but in this case there is no navigation
    private func start() {
        guard let window = window else {
            return
        }
        #if STUBS
        let assembler = ReposListAssemblerStubInjector()
        #else
        let assembler = ReposListAssemblerInjector()
        #endif
        let reposView = assembler.resolve()
        window.rootViewController = reposView
        window.makeKeyAndVisible()
    }
}

