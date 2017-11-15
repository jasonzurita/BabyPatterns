//
//  AppDelegate.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // TODO: move this into a separate initialization file
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9077495891432075~4439532342")
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
    }

    func applicationDidEnterBackground(_: UIApplication) {
    }

    func applicationWillEnterForeground(_: UIApplication) {
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }

    func applicationWillTerminate(_: UIApplication) {
    }
}
