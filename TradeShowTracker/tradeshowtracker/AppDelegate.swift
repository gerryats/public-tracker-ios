//
//  AppDelegate.swift
//  tradeshowtracker
//
//  Created by ishaan on 24/02/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    var reachability: Reachability?
    
    var hud:MBProgressHUD!
    
    let awsBucket:String = "tradeshowtrackerca"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAJWJFPIDIQ6UUETHQ", secretKey: "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")
        
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        self.addReachability()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func applicationWillResignActive(application: UIApplication)
    {
        FBSDKAppEvents.activateApp()
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    
    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    
    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK:- Reachability
    
    func addReachability()
    {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            
            return
        }
        
        reachability!.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if reachability.isReachableViaWiFi()
                {
                    print("Reachable via WiFi")
                }
                else
                {
                    print("Reachable via Cellular")
                }
            }
        }
        
        reachability!.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    
    func reachabilityChanged(note: NSNotification)
    {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable()
        {
            if reachability.isReachableViaWiFi()
            {
                print("Reachable via WiFi")
            }
            else
            {
                print("Reachable via Cellular")
            }
        }
        else
        {
            print("Not reachable")
        }
    }
    
    
    // MARK:- MBProgressHUD
    
    func showProgressHUD()
    {
        if hud != nil
        {
            hud.removeFromSuperview()
            
            hud = nil
        }
        
        hud = MBProgressHUD(window: self.window!)
        
        self.window?.addSubview(hud)
        
        hud.dimBackground = true
        
        hud.tag = 50
        
        hud.show(true)
    }
    
    
    func hideProgressHUD()
    {
        if hud != nil
        {
            hud.hide(true)
            hud.removeFromSuperview()
            hud = nil
        }
    }
}

