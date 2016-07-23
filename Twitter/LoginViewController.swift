//
//  LoginViewController.swift
//  Twitter
//
//  Created by Lam Tran on 7/19/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(sender: UIButton) {
        print("login")
        // TODO: Get request token, redirect to authURL, convert requestToken -> accessToken
        let twitterClient = BDBOAuth1SessionManager(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "4tagstOfbjGfp1igiZHh8VfxR", consumerSecret: "yIW6iNtKegBT9AtPWXzypeIsphDsFRgVuM4ztcyOJo4iwn0VWo")
        
        // To make sure whoever login before, logout first
        twitterClient.deauthorize()
        
        twitterClient.fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: NSURL(string: "twitterTTL://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            
            print("I got request token = \(requestToken.token)")
            
            // TODO: redirect to authrization url
            let authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(authUrl)
            
        }) { (error: NSError!) in
            
            print("\(error.localizedDescription)")
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
