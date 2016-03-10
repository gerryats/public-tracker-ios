//
//  FacebookViewManager.swift
//  RBS
//
//  Created by Attimac02 on 23/09/15.
//  Copyright (c) 2015 ATT. All rights reserved.
//

import UIKit

class FacebookViewManager: NSObject
{
    //MARK:- Variables
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var webObj:WebRequestViewManager = WebRequestViewManager()
    
    
    //MARK:- Class to sharedInstance
    
    class var sharedInstance: FacebookViewManager {
        
        struct Static {
            
            static var instance: FacebookViewManager?
            
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FacebookViewManager()
        }
        
        return Static.instance!
    }
    
    
    //MARK:- Method to getDataFromFacebook
    
    func loginFromFacebook(success:(responseDict:NSDictionary) -> Void ,failure:(error:NSError?) -> Void) -> Void
    {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logOut()
        
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
        
        fbLoginManager.defaultAudience = FBSDKDefaultAudience.Everyone
        
        fbLoginManager.logInWithReadPermissions(["email"/*"id", "name", "first_name", "last_name"*/], fromViewController: nil) { (result, error) -> Void in
            
            if (error == nil)
            {
                self.getFaceBookUserData({ (response) -> Void in
                    
                    print("Response : \(response)")
                    
                    success(responseDict: response)
                    
                    }, failure: { (error) -> Void in
                        
                        if error != nil
                        {
                            print("logInWithReadPermissions : \(error)")
                        }
                        
                        failure(error: error)
                })
            }
            else
            {
                print("logInWithReadPermissions outer : \(error)")
                
                failure(error: error)
            }
        }
    }
    
    
    //MARK:-  Method to getFaceBookUserData
    
    func getFaceBookUserData(success:(NSDictionary) -> Void ,failure:(NSError?) -> Void) -> Void
    {
        if((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if (error == nil)
                {
                    success (result as! NSDictionary)
                }
                else
                {
                    print("FBSDKGraphRequest : \(error)")
                    
                    failure(error)
                }
            })
        }
        else
        {
            failure(nil)
        }
    }
    
    
    // MARK:- Share on Facebook
    
    func shareImageOnFacebook(imageUrl:NSURL, fbUserDetail:NSDictionary, viewController:AddAndSharePhotoViewController)
    {
        let content = FBSDKShareLinkContent()
        
        content.contentURL = NSURL(string: "http://apptreetechnologies.com")//"http://stackoverflow.com/questions/31002389/facebook-native-share-dialog-in-swift")
        
        content.imageURL = imageUrl //NSURL(string: "http://img0.mxstatic.com/wallpapers/26e7d2c961509ccc6ad6b04056494320_large.jpeg")
        content.contentTitle = "Trade Show"
        content.contentDescription = "TradeShowTracker"
        
        let dialog : FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.FeedWeb//Automatic
        dialog.delegate = viewController
        dialog.show()
    }
}
