//
//  AddAndSharePhotoViewController.swift
//  tradeshowtracker
//
//  Created by attmac100 on 02/03/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddAndSharePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKSharingDelegate, CommentViewControllerDelegate
{
    
    // MARK:- IBOutlet
    
    @IBOutlet var ivUserPhoto:UIImageView!
    @IBOutlet var ivPlaceHolder:UIImageView!
    
    // MARK:- Variables
    
    var awsImagePath:String = ""
    var userDetail:NSDictionary = NSDictionary()
    
    var ownerComment:String = ""
    
    // MARK:- View Life Cycle
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initialSetup()
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
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
        
        if segue.identifier == "editCommentSegue"
        {
            let cVC:CommentViewController = segue.destinationViewController as! CommentViewController
            
            cVC.delegate = self
        }
    }
    
    
    // Methods
    
    func initialSetup()
    {
        self.navigationItem.hidesBackButton = true
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action:"editButtonClicked")
        
        self.navigationItem.rightBarButtonItem = editButton
        
        if Utility.isEmptyString(ownerComment)
        {
            self.getComment()
        }
    }
    
    
    func editButtonClicked()
    {
        self.performSegueWithIdentifier("editCommentSegue", sender: self)
    }
    
    
    func setImagePathAndUserDetail(sharedImagePath:String, fbUserDetail:NSDictionary)
    {
        awsImagePath = sharedImagePath
        
        userDetail = fbUserDetail
        
        let url:NSURL = NSURL(string: Utility.getAWSImagePath(awsImagePath))!
        
        FacebookViewManager.sharedInstance.shareImageOnFacebook(url, ownerComment: ownerComment, fbUserDetail: userDetail, viewController: self)
    }
    
    
    func resetImagePathAndUserDetail()
    {
        awsImagePath = ""
        
        userDetail = NSDictionary()
    }
    
    
    // MARK:- Get Image Methods
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let imgPC = UIImagePickerController()
            imgPC.delegate = self
            imgPC.sourceType = UIImagePickerControllerSourceType.Camera
            imgPC.mediaTypes = [kUTTypeImage as String]
            imgPC.allowsEditing = false
            
            self.presentViewController(imgPC, animated: true, completion: nil)
        }
            
        else
        {
            Utility.showAlert(nil, message: "Sorry! camera not available in device.", viewController: self)
        }
    }
    
    
    func openGallery()
    {
        let imgPC = UIImagePickerController()
        imgPC.delegate = self
        imgPC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imgPC.mediaTypes = [kUTTypeImage as String]
        imgPC.allowsEditing = false
        
        self.navigationController?.presentViewController(imgPC, animated: true, completion: nil)
    }
    
    
    // MARK:- IBActions
    
    @IBAction func photoButtonClicked(sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (alertAction) -> Void in
            
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Photo Library", style: .Default) { (alertAction) -> Void in
            
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (alertAction) -> Void in
            
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = CGRectMake(0, 0, self.view.frame.size.width, 300)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func sharePhoto()
    {
        if ivUserPhoto.image == nil
        {
            Utility.showAlert(nil, message: "Please capture a photo or choose from photo library.", viewController: self)
        }
            
        else
        {
            if (UIApplication.sharedApplication().delegate as! AppDelegate).reachability!.isReachable()
            {
                (UIApplication.sharedApplication().delegate as! AppDelegate).showProgressHUD()
                
                var imagePath:String = Utility.getOwnerEmail() + "/\(NSDate().timeIntervalSince1970 * 1000).jpg"
                
                if !Utility.isEmptyString(self.awsImagePath)
                {
                    imagePath = self.awsImagePath
                }
                
                print("This is the path of aws image : \(imagePath)")
                
                AWSViewManager.sharedInstance.uploadImageToAWS(ivUserPhoto.image!, atPath: imagePath, uploaded: { (result) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
//                        (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                        
                        self.newFacebookLogin(imagePath)
                    })
                    
                    }, failure: { (error) -> Void in
                        
                        (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                        
                        Utility.showServerErrorAlert(self)
                })
            }
            else
            {
                Utility.showInternetAlert(self)
            }
        }
    }
    
    
    //MARK:- UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        ivUserPhoto.image = image
        
        ivPlaceHolder.hidden = true
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK:- Upload process
    
    func newFacebookLogin(imagePath:String)
    {
        FacebookViewManager.sharedInstance.loginFromFacebook({ (responseDict) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
//                print("Response of facebook : \(responseDict)")
                
                self.setImagePathAndUserDetail(imagePath, fbUserDetail: responseDict)
                
//                FacebookViewManager.sharedInstance.shareImageOnFacebook(self)
            })
            
            }) { (error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    print("error: \(error)")
                    
                    (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                    
                    Utility.showServerErrorAlert(self)
                })
        }
    }
    
    
    func uploadDetailFBDetails()
    {
//        (UIApplication.sharedApplication().delegate as! AppDelegate).showProgressHUD()
        
        let paramDict:NSMutableDictionary = NSMutableDictionary()
        
        if let firstName:String = userDetail.valueForKey("first_name") as? String{
            paramDict.setValue(firstName, forKey: "first_name")
        } else {
            paramDict.setValue("", forKey: "first_name")
        }
        
        if let lastName:String = userDetail.valueForKey("last_name") as? String{
            paramDict.setValue(lastName, forKey: "last_name")
        } else {
            paramDict.setValue("", forKey: "last_name")
        }
        
        if let email:String = userDetail.valueForKey("email") as? String{
            paramDict.setValue(email, forKey: "email")
        } else {
            paramDict.setValue("", forKey: "email")
        }
        
        paramDict.setValue(Utility.getAWSImagePath(awsImagePath), forKey: "image_url")
        paramDict.setValue(Utility.getOwnerEmail(), forKey: "owner_email_id")
        
        APIViewManager.sharedInstance.uploadFBShareDetail(paramDict, success: { (responseDict) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
                
                if let errCode:Int = responseDict.valueForKey("error_code") as? Int
                {
                    print("Response of post comment : \(responseDict)")
                    
                    if errCode == 0     // uploaded
                    {
                        self.resetImagePathAndUserDetail()
                        
                        Utility.showAlert(nil, message: "Thanks for sharing.", viewController: self)
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
                })
        }
    }
    
    
    // MARK:- Get Comment
    
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
                                self.ownerComment = comment
                            }
                        }
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
    
    
    
    // MARK:- FBSDKSharingDelegate
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!)
    {
//        print("results : \(results)")
        
        /*self.resetImagePathAndUserDetail()
        
        Utility.showAlert(nil, message: "Thanks for sharing.", viewController: self)*/
        
        self.uploadDetailFBDetails()
    }
    
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!)
    {
        /*print("error : \(error)\n")
        print("error description : \(error.description)\n")
        print("error localizedDescription : \(error.localizedDescription)")*/
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
        
        Utility.showAlert("Sharing Failed", message: "Please try again.", viewController: self)
    }
    
    
    func sharerDidCancel(sharer: FBSDKSharing!)
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).hideProgressHUD()
//        print("Canceled")
    }
    
    
    // MARK:- Comment View Controller
    
    func ownerCommentUpdated(newComment: String)
    {
        ownerComment = newComment
    }
}
