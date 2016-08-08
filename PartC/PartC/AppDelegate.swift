//
//  AppDelegate.swift
//  PartC
//
//  Created by Nam Nguyen on 25/09/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let iCloudIdentityToken = NSFileManager.defaultManager().ubiquityIdentityToken
        
        if iCloudIdentityToken != nil {
            print("We have iCloud support")
        } else {
            print("We don't have iCloud support")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "iCloudKeysChanged:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
        
        // Start iCloud key-value updates
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        
        updateUserDefaultsFromIcloud()
        
        return true
    }
    
    func iCloudKeysChanged(notification: NSNotification) {
        updateUserDefaultsFromIcloud()
    }
    
    // Update Storage Type from iCloud to User Defaults
    private func updateUserDefaultsFromIcloud() {
        let values = NSUbiquitousKeyValueStore.defaultStore().dictionaryRepresentation
        if values[Constant.DataKey.StorageType] != nil {
            let storageType = Int(NSUbiquitousKeyValueStore.defaultStore().longLongForKey(Constant.DataKey.StorageType))
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(storageType, forKey: Constant.DataKey.StorageType)
            prefs.synchronize()
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

