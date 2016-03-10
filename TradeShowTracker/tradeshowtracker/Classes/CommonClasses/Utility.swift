//
//  Utility.swift
//  tradeshowtracker
//
//  Created by attmac100 on 07/03/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

class Utility: NSObject
{
    
    // MARK:- Alert
    
    class func showAlert(title: String?, message: String?, viewController:UIViewController)
    {
        let alertController:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    class func showInternetAlert(viewController:UIViewController)
    {
        let alertController = UIAlertController(title: "Oops!", message: "Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    class func showServerErrorAlert(viewController:UIViewController)
    {
        let alertController = UIAlertController(title: nil, message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK:- Valid emails
    
    class func isValidEmail(email:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let range = email.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        
        let result = range != nil ? true : false
        
        return result
    }
    
    
    // MARK:- Empty string
    
    class func isEmptyString(string:String) -> Bool
    {
        if string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0
        {
            return true
        }
        
        return false
    }
    
    
    class func trimString(string:String) -> String
    {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    
    // MARK:- Check login status
    
    class func isUserLoggedIn() -> Bool
    {
        if let _:String = NSUserDefaults.standardUserDefaults().valueForKey("ownerEmail") as? String
        {
            return true
        }
        
        return false
    }
    
    
    // MARK:- Save login userdefaults
    
    class func saveLoginDetails(loginDetail:NSDictionary)
    {
        if let id:Int = loginDetail.valueForKey("id") as? Int
        {
            NSUserDefaults.standardUserDefaults().setInteger(id, forKey: "id")
        }
        
        if let companyName:String = loginDetail.valueForKey("company_name") as? String
        {
            NSUserDefaults.standardUserDefaults().setValue(companyName, forKey: "companyName")
        }
        
        if let tradeShowName:String = loginDetail.valueForKey("trade_show_name") as? String
        {
            NSUserDefaults.standardUserDefaults().setValue(tradeShowName, forKey: "tradeShowName")
        }
        
        if let ownerEmail:String = loginDetail.valueForKey("owner_email_id") as? String
        {
            NSUserDefaults.standardUserDefaults().setValue(ownerEmail, forKey: "ownerEmail")
        }
        
        if let validity:Int = loginDetail.valueForKey("validity") as? Int
        {
            NSUserDefaults.standardUserDefaults().setInteger(validity, forKey: "validity")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    class func removeLoginDetail()
    {
        if let _:Int = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("id")
        }
        
        if let _:String = NSUserDefaults.standardUserDefaults().valueForKey("companyName") as? String
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("companyName")
        }
        
        if let _:String = NSUserDefaults.standardUserDefaults().valueForKey("tradeShowName") as? String
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("tradeShowName")
        }
        
        if let _:String = NSUserDefaults.standardUserDefaults().valueForKey("ownerEmail") as? String
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("ownerEmail")
        }
        
        if let _:Int = NSUserDefaults.standardUserDefaults().valueForKey("validity") as? Int
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("validity")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    class func getCompanyID() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("id")
    }
    
    class func getCompanyName() -> String {
        return NSUserDefaults.standardUserDefaults().valueForKey("companyName") as! String
    }
    
    class func getTradeShowName() -> String {
        return NSUserDefaults.standardUserDefaults().valueForKey("tradeShowName") as! String
    }
    
    class func getOwnerEmail() -> String {
        return NSUserDefaults.standardUserDefaults().valueForKey("ownerEmail") as! String
    }
    
    class func getValidity() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("validity")
    }
    
    // MARK:- AWS Utilities
    
    class func getAWSImagePath(imagePath:String) -> String      // image path will contain email/imagename
    {
        let buckect = (UIApplication.sharedApplication().delegate as! AppDelegate).awsBucket
        
        let completePath = "https://s3.amazonaws.com/\(buckect)/\(imagePath)"
        
        return completePath
    }
}
