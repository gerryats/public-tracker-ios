//
//  AWSViewManager.swift
//  tradeshowtracker
//
//  Created by attmac100 on 03/03/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

class AWSViewManager: NSObject
{
    //MARK:- Class to sharedInstance
    
    class var sharedInstance: AWSViewManager {
        
        struct Static {
            
            static var instance: AWSViewManager?
            
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AWSViewManager()
        }
        
        return Static.instance!
    }
    
    
    // MARK:- Upload to AWS
    
    func uploadImageToAWS(image:UIImage, atPath imagePath:String, uploaded:(result:AnyObject?) -> Void, failure:(error:NSError?) -> Void)
    {
        // saving image temporary
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0);
        
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let imageData = UIImageJPEGRepresentation(newImage, 0.0) // UIImagePNGRepresentation(image)//
        
        let filePath = NSTemporaryDirectory().stringByAppendingString("fileName.jpg")
        
        imageData?.writeToFile(filePath, atomically: true)
        
        // Creating upload request
        
        let uploadRequest:AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = (UIApplication.sharedApplication().delegate as! AppDelegate).awsBucket //"tradeshowtrackerca"
        uploadRequest.key = imagePath
        
        
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        
        // Uploading image
        
        let transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error != nil
            {
                if task.error?.domain == AWSS3TransferManagerErrorDomain
                {
                    switch task.error!.code
                    {
                    case AWSS3TransferManagerErrorType.Cancelled.rawValue:
                        
                        break
                        
                    case AWSS3TransferManagerErrorType.Paused.rawValue:
                        
                        break
                        
                    default:
                        
                        print("Error in upload default: \(task.error?.description)")
                        
                        break
                    }
                }
                
                print("Error in upload: \(task.error)")
                
                failure(error: task.error)
            }
            
            else if task.result != nil
            {
                print("task.result : \(task.result)")
                
                uploaded(result: task.result)
            }
            
            return nil
        }
    }
}
