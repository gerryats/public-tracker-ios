//
//  WebRequestViewManager.swift
//  Swoppler
//
//  Created by Brian on 09/07/15.
//  Copyright (c) 2015 com.trend. All rights reserved.
////let baseURL = "http://192.168.0.109:3001/api/v1/"


import UIKit


let baseURL = ""


class WebRequestViewManager: NSObject
{
    //MARK:- Variables
    
    var config : NSURLSessionConfiguration!
    var session : NSURLSession!
    
    //MARK:- init method
    
    override init()
    {
        config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }
    
    
    //MARK:- Method to getRequestWithEndPoint
    
    func getRequestWithEndPoint(urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam("GET", urlString: urlString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        task.resume()
    }
    
    
    //MARK:- Post request With Base URL
    
    func postRequest(urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam("POST", urlString: NSURL(string: baseURL)!.URLByAppendingPathComponent(urlString as String).absoluteString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        task.resume()
    }
    
    
    //MARK:- POST Request with endpoints
    
    func postRequestWithEndPoint(urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam("POST", urlString: urlString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        task.resume()
    }
    
    
    //MARK:- Method to deleteRequestWithEndPoint
    
    func deleteRequestWithEndPoint(urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam("DELETE", urlString: urlString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        
        task.resume()
    }
    
    
    //MARK:- Method to putRequestWithEndPoint
    
    func putRequestWithEndPoint(urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam("PUT", urlString: urlString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        
        task.resume()
    }
    
    
    //MARK:-  Request with param&Method
    
    func requestWithMethodAndParameter(method:String, urlString:String, parameters:NSDictionary?, success:(NSData!) -> Void, failure:(NSError!) -> Void) -> Void
    {
        let request:NSMutableURLRequest = self.requestWithMethodAndParam(method, urlString: urlString, parameters: parameters)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil)
            {
                success(data)
            }
                
            else
            {
                failure(error)
            }
        })
        
        task.resume()
    }
    
    
    //MARK:- Creating URLRequest
    
    func requestWithMethodAndParam(method:String, urlString:String, parameters:NSDictionary?) -> NSMutableURLRequest{
        
//        let url:NSURL = NSURL(string: urlString as String)!
        
        let url:NSURL = NSURL(string: urlString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!//stringByRemovingPercentEncoding!
        
        let mutableRequest:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        mutableRequest.HTTPMethod = method as String
        mutableRequest.allowsCellularAccess = true;
        mutableRequest.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy;
        mutableRequest.HTTPShouldHandleCookies = true;
        mutableRequest.HTTPShouldUsePipelining = false;
        mutableRequest.networkServiceType = NSURLRequestNetworkServiceType.NetworkServiceTypeDefault
        mutableRequest.timeoutInterval = 60;
        
        if (parameters != nil)
        {
            mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            
            if method == "POST"
            {
                mutableRequest.setValue("application/json; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                //              getResponseDic = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                
                do {
                    mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: [])
                }
                catch {
                    print("json error: \(error)")
                }
            }
            else if method == "PUT"
            {
                mutableRequest.setValue("application/json; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                do {
                    mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: [])
                }
                catch {
                    print("json error: \(error)")
                }
            }
            else if method == "DELETE"
            {
                mutableRequest.setValue("application/json; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                do {
                    mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: [])
                }
                catch {
                    print("json error: \(error)")
                }
            }
                
            else if method == "GET"
            {
                let urlStr:NSMutableString = urlString.mutableCopy() as! NSMutableString
                
                urlStr.appendString("?")
                
                for keys in parameters!.allKeys
                {
                    let keyString:NSString = keys as! NSString
                    
                    if (urlStr.substringFromIndex(urlStr.length - 1) == "?")
                    {
                        
                        urlStr.appendString("\(keyString)=\(parameters?.valueForKey(keyString as String) as! NSString)")
                    }
                    else
                    {
                        urlStr.appendString("&\(keyString)=\(parameters?.valueForKey(keyString as String) as! NSString)")
                    }
                }
//                mutableRequest.URL = NSURL(string: urlStr as String)
                
                mutableRequest.URL = NSURL(string: urlStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            }
        }
        return mutableRequest;
    }
}
