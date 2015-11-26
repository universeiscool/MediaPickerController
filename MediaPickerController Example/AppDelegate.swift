//
//  AppDelegate.swift
//  MediaPickerController Example
//
//  Created by Malte Schonvogel on 22.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow? = UIWindow()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        window?.frame = UIScreen.mainScreen().bounds
        window?.backgroundColor = UIColor.whiteColor()
        
        // Request authorization before showing media picker.
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            switch status {
            case .Authorized:
                let vc = MediaPickerController(mediaPickerOptions: nil)
                vc.doneClosure = { (assets: [PHAsset], momentTitle:String?, mediaPickerController:MediaPickerController) in
                    if let momentTitle = momentTitle {
                        print("Selected Moment '\(momentTitle)': \(assets.count) assets")
                    } else {
                        print("Selected Assets: \(assets.count) assets")
                    }
                }
                vc.cancelClosure = { (mediaPickerController:MediaPickerController) in
                    print("cancel")
                }
                self.window?.rootViewController = vc
            default:
                self.window?.rootViewController = UIViewController()
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
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

