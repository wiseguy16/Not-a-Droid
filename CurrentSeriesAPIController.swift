//
//  CurrentSeriesAPIController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/3/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import Foundation
import UIKit

class CurrentSeriesAPIController
{
    
    
    init(delegate: CurrentSeriesAPIControllerProtocol)
    {
        self.delegate = delegate
    }
    
    
    //var arrayOfFeatured = [Featured]()
    // var arrayOfBlogs = [Featured]()
    var arrayOfSeries = [SeriesItem]()
    var arrayOfConfiguration = [SeriesItem]()
    
    var delegate: CurrentSeriesAPIControllerProtocol!
    let baseURLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getseries/"
    
    
    func removeSpecialCharsFromString(str: String) -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_/@[]{}".characters)
        return String(str.characters.filter { chars.contains($0) })
    }
    
    func removeBackslashes(str: String) -> String
    {
        var newStr = str
        newStr = newStr.stringByReplacingOccurrencesOfString("\t", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\n", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\\", withString: "")
        
        return newStr
    }
    
    
    func getCurrentSeriesDataFromNACD(thisSession: String)
    {
        //  "h ttp://www.northlandchurch.net/index.php/resources/iphone-app-getseries"
        
        let URLString = baseURLString + thisSession
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        //request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let httpResponse = response as? NSHTTPURLResponse
                {   print(httpResponse)
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }
                
                if let apiData = data
                {   //print(apiData)
                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
                    {
                        
                        //print(datastring)
                        let data2 = self.removeBackslashes(datastring)
                       // print(data2)
                        let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
                        //print(data1!)
                        
                        if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
                        {
                            let dataArray = myJSON["items"] as? [[String: AnyObject]]
                            
                            if let constArray = dataArray
                            {
                                for value in constArray
                                {
                                    let aSrs = SeriesItem(myDictionary: value)
                                    self.arrayOfSeries.append(aSrs)
                                }
                                self.delegate.gotTheSeries(self.arrayOfSeries)
                            }
                        }
                    }
                }
                else
                {
                    self.networkAlert()
                    //  self.delegate.gotTheBible(self.arrayOfLiturgy)
                }
                
            })
        })
        
        
        task.resume()
        
        return
    }
    
    
    
    func getSeriesConfigurationDataFromNACD()
    {
        //  "h ttp://www.northlandchurch.net/index.php/resources/iphone-app-getseries"
        
        let URLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getsession"
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        //request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let httpResponse = response as? NSHTTPURLResponse
                {   print(httpResponse)
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }
                
                if let apiData = data
                {   //print(apiData)
                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
                    {
                        
                        //print(datastring)
                        let data2 = self.removeBackslashes(datastring)
                        // print(data2)
                        let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
                        //print(data1!)
                        
                        if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
                        {
                            let dataArray = myJSON["items"] as? [[String: AnyObject]]
                            
                            if let constArray = dataArray
                            {
                                for value in constArray
                                {
                                    let aSrs = SeriesItem(myDictionary: value)
                                    self.arrayOfConfiguration.append(aSrs)
                                }
                                self.delegate.gotTheConfigSettings(self.arrayOfConfiguration)
                            }
                        }
                    }
                }
                else
                {
                    self.networkAlert()
                    //  self.delegate.gotTheBible(self.arrayOfLiturgy)
                }
                
            })
        })
        
        
        task.resume()
        
        return
    }

    
    
    
    func purgeSeries()
    {
        arrayOfSeries.removeAll()
    }
    
    func purgeSettings()
    {
        arrayOfConfiguration.removeAll()
    }
    
    func networkAlert()
    {
        // Create the alert controller
        let alertController1 = UIAlertController(title: "Sorry, having trouble connecting to the network. Please try again later.", message: "Network Unavailable", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        // Present the controller
        alertController1.show()
    }
    
  //
    
    
}