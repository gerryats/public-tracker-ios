//
//  ViewController.swift
//  tradeshowtracker
//
//  Created by ishaan on 24/02/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate
{
    // MARK:- Outlets
    
    @IBOutlet var txtCompanyName:UITextField!
    @IBOutlet var txtTradeShowName:UITextField!
    @IBOutlet var txtOwnerEmail:UITextField!
    @IBOutlet var txtValidity:UITextField!
    
    @IBOutlet var topLayOut:NSLayoutConstraint!
    
    // MARK:- View Life Cycle
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.intitalSetup()
        
        self.title = "SignUp/SignIn"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: "UIDeviceOrientationDidChangeNotification", object: nil)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.intitalSetup()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "commentSegue"
        {
            let commentVC = segue.destinationViewController as! CommentViewController
            
            commentVC.isNewUser = true
        }
        
        else if segue.identifier == "addAndShareSegue"
        {
            /*if segue.destinationViewController is AddAndSharePhotoViewController
            {
                print(segue.identifier)
            }*/
        }
    }
    
    
    // MARK:- Methods
    
    func intitalSetup()
    {
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)    // Landscape
        {
            topLayOut.constant = 50
        }
        
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) // Portrait
        {
            topLayOut.constant = 200
        }
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
        
        if Utility.isUserLoggedIn()
        {
            txtCompanyName.text = Utility.getCompanyName()
            txtTradeShowName.text = Utility.getTradeShowName()
            txtOwnerEmail.text = Utility.getOwnerEmail()
            txtValidity.text = "\(Utility.getValidity())"
            
            self.signUpOrLogin()
        }
    }
    
    
    func signUpOrLogin()
    {
        if Utility.isEmptyString(txtCompanyName.text!) || Utility.isEmptyString(txtTradeShowName.text!) || Utility.isEmptyString(txtOwnerEmail.text!) || Utility.isEmptyString(txtValidity.text!)
        {
            Utility.showAlert(nil, message: "Please fill all fields.", viewController: self)
        }
            
        else if !Utility.isValidEmail(txtOwnerEmail.text!)
        {
            Utility.showAlert(nil, message: "Please enter a valid email address", viewController: self)
        }
        
        else if let _:Int = Int(txtValidity.text!)
        {
            (UIApplication.sharedApplication().delegate as! AppDelegate).showProgressHUD()
            
            let paramDict:NSMutableDictionary = NSMutableDictionary()
            paramDict.setValue(Utility.trimString(txtCompanyName.text!), forKey: "company_name")
            paramDict.setValue(Utility.trimString(txtTradeShowName.text!), forKey: "trade_show_name")
            paramDict.setValue(Utility.trimString(txtOwnerEmail.text!), forKey: "owner_email_id")
            paramDict.setValue(Utility.trimString(txtValidity.text!), forKey: "validity")
            
            APIViewManager.sharedInstance.createAccount(paramDict, success: { (responseDict) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                    
                    if let errCode:Int = responseDict.valueForKey("error_code") as? Int
                    {
                        print("Response of login : \(responseDict)")
                        
                        if errCode == 0     // Normal Login
                        {
                            if let company:NSDictionary = responseDict.valueForKey("company") as? NSDictionary
                            {
                                Utility.saveLoginDetails(company)
                            }
                            
                            self.performSegueWithIdentifier("addAndShareSegue", sender: self)
                        }
                        
                        else if errCode == 1    // New user registered
                        {
                            if let company:NSDictionary = responseDict.valueForKey("company") as? NSDictionary
                            {
                                Utility.saveLoginDetails(company)
                            }
                            
                            self.performSegueWithIdentifier("commentSegue", sender: self)
                        }
                        
                        else
                        {
                            /*
                            error_code:2, message: "Your validity is over. Please contact Admin.",
                            error_code:3, message: "There is already another company registered for this Email.”
                            */
                            
                            Utility.removeLoginDetail()
                            
                            if let message:String = responseDict.valueForKey("message") as? String
                            {
                                Utility.showAlert(nil, message: message, viewController: self)
                            }
                            else
                            {
                                Utility.showServerErrorAlert(self)
                            }
                        }
                    }
                    
                    else
                    {
                        Utility.showServerErrorAlert(self)
                    }
                })
                
                }, failure: { (error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                        
                        print("<><><><> : \(error)")
                        
                        Utility.showServerErrorAlert(self)
                    })
            })
        }
        
        else
        {
            Utility.showAlert(nil, message: "Please fill a valid validity value in days.", viewController: self)
        }
    }
    
    
    // MARK:- IBAction
    
    @IBAction func signUpButtonClicked(sender: UIButton)
    {
        self.view.endEditing(true)
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).reachability!.isReachable()
        {
            self.signUpOrLogin()
        }
        else
        {
            Utility.showInternetAlert(self)
        }
    }
    
    
    // MARK:- TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == txtCompanyName
        {
            txtTradeShowName.becomeFirstResponder()
        }
        
        else if textField == txtTradeShowName
        {
            txtOwnerEmail.becomeFirstResponder()
        }
        
        else if textField == txtOwnerEmail
        {
            txtValidity.becomeFirstResponder()
        }
        
        else if textField == txtValidity
        {
            self.signUpOrLogin()
        }
        
        else
        {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    // MARK:- Auto rotation
    
    override func shouldAutorotate() -> Bool
    {
        return false
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    func orientationChanged(sender: NSNotification)
    {
        // Here check the orientation using this:
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)    // Landscape
        {
            topLayOut.constant = 50
        }
        
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) // Portrait
        {   
            topLayOut.constant = 200
        }
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
        // Now once only allow the portrait one to go in that conditional part of the view. If you're using a navigation controller push the vc otherwise just use presentViewController:animated:
        
    }
    
}

