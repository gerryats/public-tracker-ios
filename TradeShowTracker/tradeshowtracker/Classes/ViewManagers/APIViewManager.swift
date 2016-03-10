//
//  APIViewManager.swift
//  tradeshowtracker
//
//  Created by attmac100 on 07/03/16.
//  Copyright © 2016 AppTreeTechnologies. All rights reserved.
//

import UIKit

let baseUrlV1 = "http://23.23.217.43/api/v1/"//"http://192.168.0.130:3000/api/v1/"
//http://23.23.217.43/

class APIViewManager: NSObject
{
    // MARK:- 
    
    var webObj:WebRequestViewManager = WebRequestViewManager()
    
    //MARK:- Class to sharedInstance
    
    class var sharedInstance: APIViewManager {
        
        struct Static {
            
            static var instance: APIViewManager?
            
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = APIViewManager()
        }
        
        return Static.instance!
    }
    
    
    // MARK:- Login/SignUp API
    
    func createAccount(parameters:NSDictionary?, success:(responseDict:NSDictionary) -> Void, failure:(error:NSError?) -> Void)
    {
        // http://192.168.0.130:3000/api/v1/company/create.json post call
        // parameter: company_name, trade_show_name, owner_email_id, validity
        
        let strRequest = baseUrlV1 + "company/create.json"
        
        webObj.postRequestWithEndPoint(strRequest, parameters: parameters, success: { (responseData) -> Void in
            
            do
            {
                let responseDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                success(responseDict: responseDict)
            }
            
            catch let error as NSError
            {
                print("Catch create account: \(error)")
                
                failure(error: error)
            }
            
            }) { (error) -> Void in
                
                print("create account error: \(error)")
                
                failure(error: error)
        }
    }
    
    
    // MARK:- Get Comment
    
    func getComment(/*parameters:NSDictionary?, */success:(responseDict:NSDictionary) -> Void, failure:(error:NSError?) -> Void)
    {
        // http://192.168.0.130:3000/api/v1/company/get_comment.json get call
        // parameter: owner_email_id
        
        let strRequest = baseUrlV1 + "company/get_comment.json"
        
        webObj.getRequestWithEndPoint(strRequest, parameters: NSDictionary(object: Utility.getOwnerEmail(), forKey: "owner_email_id"), success: { (responseData) -> Void in
            
            do
            {
                let responseDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                success(responseDict: responseDict)
            }
                
            catch let error as NSError
            {
                print("Catch get comment: \(error)")
                
                failure(error: error)
            }
            
            }) { (error) -> Void in
                
                print("get comment error: \(error)")
                
                failure(error: error)
        }
    }
    
    
    // MARK:- Post Comment
    
    func postComment(parameters:NSDictionary?, success:(responseDict:NSDictionary) -> Void, failure:(error:NSError?) -> Void)
    {
        // http://192.168.0.130:3000/api/v1/company/add_comment.json post call
        // parameter: owner_email_id, comment
        
        let strRequest = baseUrlV1 + "company/add_comment.json"
        
        webObj.postRequestWithEndPoint(strRequest, parameters: parameters, success: { (responseData) -> Void in
            
            do
            {
                let responseDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                success(responseDict: responseDict)
            }
                
            catch let error as NSError
            {
                print("Catch post comment: \(error)")
                
                failure(error: error)
            }
            
            }) { (error) -> Void in
                
                print("post comment error: \(error)")
                
                failure(error: error)
        }
    }
    
    
    // MARK:- Upload fb share Details with image
    
    func uploadFBShareDetail(parameters:NSDictionary?, success:(responseDict:NSDictionary) -> Void, failure:(error:NSError?) -> Void)
    {
        // http://192.168.0.130:3000/api/v1/users/create.json post call
        // parameter: first_name, last_name, email, image_url, owner_email_id
        
        let strRequest = baseUrlV1 + "users/create.json"
        
        webObj.postRequestWithEndPoint(strRequest, parameters: parameters, success: { (responseData) -> Void in
            
            do
            {
                let responseDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                success(responseDict: responseDict)
            }
                
            catch let error as NSError
            {
                print("Catch upload: \(error)")
                
                failure(error: error)
            }
            
            }) { (error) -> Void in
                
                print("upload error: \(error)")
                
                failure(error: error)
        }
    }
}
