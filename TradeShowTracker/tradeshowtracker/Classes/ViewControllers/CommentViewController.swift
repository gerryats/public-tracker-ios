//
//  CommentViewController.swift
//  tradeshowtracker
//
//  Created by attmac100 on 02/03/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITextViewDelegate
{
    // MARK:- Outlets
    
    @IBOutlet var tvComment:UITextView!
    
    
    // MARK:- Variables
    
    let tvPlaceHolder:String = "Your comment"
    
    var isNewUser:Bool = false
    
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initialSetup()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK:- Methods
    
    
    func initialSetup()
    {
        tvComment.text = ""
        
        tvComment.layer.borderColor = UIColor.blackColor().CGColor
        tvComment.layer.borderWidth = 1.0
        
        if isNewUser == true
        {
            self.navigationItem.hidesBackButton = true
            
            tvComment.text = tvPlaceHolder
            
            self.setTextViewColor()
        }
        
        else
        {
            self.getComment()
        }
    }
    
    
    // MARK:- Server call methods
    
    func getComment()
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).showProgressHUD()
        
        APIViewManager.sharedInstance.getComment({ (responseDict) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                
                if let errCode:Int = responseDict.valueForKey("error_code") as? Int
                {
//                    print("Response of get comment : \(responseDict)")
                    
                    if errCode == 0     // Comment received
                    {
                        if let comment:String = responseDict.valueForKey("comment") as? String
                        {
                            if Utility.trimString(comment).characters.count > 0
                            {
                                self.tvComment.text = comment
                            }
                            else
                            {
                                self.tvComment.text = self.tvPlaceHolder
                            }
                        }
                        else
                        {
                            self.tvComment.text = self.tvPlaceHolder
                        }
                        
                        self.setTextViewColor()
                    }
                    else
                    {
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
            }) { (error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                    
                    Utility.showServerErrorAlert(self)
                })
        }
    }
    
    
    func postComment()
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).showProgressHUD()
        
        let paramDict:NSMutableDictionary = NSMutableDictionary()
        paramDict.setValue(Utility.trimString(tvComment.text!), forKey: "comment")
        paramDict.setValue(Utility.getOwnerEmail(), forKey: "owner_email_id")
        
        APIViewManager.sharedInstance.postComment(paramDict, success: { (responseDict) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                
                if let errCode:Int = responseDict.valueForKey("error_code") as? Int
                {
//                    print("Response of post comment : \(responseDict)")
                    
                    if errCode == 0     // Comment posted
                    {
                        self.commentPosted()
                    }
                    else
                    {
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
            }) { (error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                    
                    Utility.showServerErrorAlert(self)
                })
        }
    }
    
    
    func commentPosted()
    {
        if isNewUser
        {
            let vcs = NSMutableArray(array: (self.navigationController?.viewControllers)!)
            
            let picVC:AddAndSharePhotoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddAndSharePhotoViewController") as! AddAndSharePhotoViewController
            
            vcs.replaceObjectAtIndex(1, withObject: picVC)
            
            self.navigationController?.setViewControllers(((vcs.copy() as! NSArray) as! [UIViewController]), animated: true)
        }
        else
        {
//            Utility.showAlert(nil, message: "Comment updated.", viewController: self)
            
            let alertController:UIAlertController = UIAlertController(title: nil, message: "Comment updated.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK:- IBAction
    
    @IBAction func postCommentAction(button:UIButton)
    {
        self.view.endEditing(true)
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).reachability!.isReachable()
        {
            if Utility.isEmptyString(tvComment.text!) || tvComment.text == tvPlaceHolder
            {
                Utility.showAlert(nil, message: "Please type your comment.", viewController: self)
            }
            else
            {
                self.postComment()
            }
        }
        else
        {
            Utility.showInternetAlert(self)
        }
    }
    
    
    // MARK:- TextView text color setting
    
    func setTextViewColor()
    {
        if Utility.isEmptyString(tvComment.text!) || tvComment.text! == tvPlaceHolder
        {
            tvComment.textColor = UIColor.lightGrayColor()
        }
        
        else
        {
            tvComment.textColor = UIColor.darkTextColor()
        }
    }
    
    
    // MARK:- TextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView == tvComment
        {
            if tvComment.text! == tvPlaceHolder
            {
               tvComment.text = ""
            }
            
            tvComment.textColor = UIColor.darkTextColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if textView == tvComment && Utility.isEmptyString(textView.text!)
        {
            textView.text = tvPlaceHolder
        }
        
        self.setTextViewColor()
    }
}
