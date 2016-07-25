//
//  TwitterClient.swift
//  Twitter
//
//  Created by Lam Tran on 7/23/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

    static let shareInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "w5azmZN4va4Vxp0j0C07O467v", consumerSecret: "0BlZ7vI7ZntFzWukTfD4zmTXc3vF6GjJCjdPq0AwgI29cMVyfw")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    //  MARK: 
    func login(success: () -> (), failure: (NSError) -> ()){
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.shareInstance.deauthorize()
        TwitterClient.shareInstance.fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: NSURL(string: "twitterTTL://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            
            print("I got request token = \(requestToken.token)")
            
            // TODO: redirect to authrization url
            let authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(authUrl)
            
        }) { (error: NSError!) in
            print("\(error.localizedDescription)")
            self.loginFailure?(error)
            
        }
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            
            self.loginSuccess?()
        
        }) { (error: NSError!) in
            self.loginFailure?(error)
        }

    }
    
    //  MARK: Get Home Timeline
    func homeTimeLine(count: Int?, success: [Tweet] -> (), failure: (NSError) -> ()){
        var parameters = [String:AnyObject]()
        
        if count != nil {
            parameters["count"] = count!
        }
        
        
        GET("1.1/statuses/home_timeline.json", parameters: parameters, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            
            //                print(response)
            success(tweets)
            
            for tweet in tweets {
                print(tweet.text!)
                print(tweet.user?.screenName)
            }
            
            }, failure: { (task:NSURLSessionDataTask?, error: NSError) in
                print("\(error.localizedDescription)")
                failure(error)
        })
    }
    
    //  MARK: -Get Current Account
    func currentAccount(success: User -> (), failure: (NSError) -> ()){
        GET("1.1/account/verify_credentials.json", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
            print("\(user.name!)")
            print("\(user.screenName!)")
            print("\(user.tagline!)")
            print("\(user.profileImageUrl)")
                        
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                print("\(error.localizedDescription)")
                failure(error)
        })
    }
    
    //  MARK: UpdateStatus
    func updateStatus(status: String, success: (Tweet) -> (), failure: (NSError) -> ()){
        var parameters = [String:AnyObject]()
        parameters["status"] = status
        
        
        POST("1.1/statuses/update.json", parameters: parameters, success: { (task:NSURLSessionDataTask, reponse: AnyObject) in
            print("Updated status success")
            
            let newTweet = Tweet(dictionary: reponse as! NSDictionary)
            success(newTweet)

            
        }) { (task:NSURLSessionDataTask?, error: NSError) in
            print("Error on post status: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func replyStatus(status: String, originalId: NSNumber, success: (Tweet) -> (), failure: (NSError) -> ()) {
        var parameters = [String : AnyObject]()
        parameters["status"] = status
        parameters["in_reply_to_status_id"] = originalId
        
        POST("1.1/statuses/update.json", parameters: parameters, success: { (task:NSURLSessionDataTask, reponse:AnyObject) in
            
            let newTweet = Tweet(dictionary: reponse as! NSDictionary)
            success(newTweet)
            
        }) { (task:NSURLSessionDataTask?, error:NSError) in
            failure(error)
        }
    }
    
    // MARK: Update Favorite
    
    func favoriteTweet(id: NSNumber, success: AnyObject -> (), failure: (NSError) -> ()) {
        
        var parameters = [String : AnyObject]()
        parameters["id"] = id
        
        POST("1.1/favorites/create.json", parameters: parameters, success: { (task: NSURLSessionDataTask, reponse: AnyObject) in
            success (reponse)
        }) { (taslk:NSURLSessionDataTask?, error:NSError) in
                failure(error)
        }
    }
    
    func unfavoriteTweet(id: NSNumber, success: AnyObject -> (), failure: (NSError) -> ()) {
        var parameters = [String : AnyObject]()
        parameters["id"] = id
        
        POST("1.1/favorites/destroy.json", parameters: parameters, success: { (task: NSURLSessionDataTask, reponse: AnyObject) in
            success (reponse)
        }) { (taslk:NSURLSessionDataTask?, error:NSError) in
            failure(error)
        }
        
    }
    
    //  MARK: Update Retweet
    
    func getRetweetedId(id: NSNumber, success: NSDictionary -> () , failure: (NSError) -> ()) {
        
        var parameters = [String : AnyObject]()
        parameters["include_my_retweet"] = true
        
        GET("1.1/statuses/show/\(id).json", parameters: parameters, success: { (task: NSURLSessionDataTask, reponse: AnyObject) in
            let tweet = reponse as! NSDictionary
            success(tweet)
            
        }) { (task:NSURLSessionDataTask?, error:NSError) in
            print(error.localizedDescription)
            failure(error)
        }
        
    }
    
    
    func retweet(id: NSNumber, success: (NSDictionary) -> () , failure: (NSError) -> ()) {
        
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, success: { (task:NSURLSessionDataTask, reponse:AnyObject) in
            let tweet = reponse as! NSDictionary
            success(tweet)
            
        }) { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
                print("Error retweet!")
        }
        
    }
    
   
    func unretweet(id: NSNumber, success: (NSDictionary) -> () , failure: (NSError) -> ()) {
        POST("1.1/statuses/destroy/\(id).json", parameters: nil, success: { (task:NSURLSessionDataTask, reponse:AnyObject) in
            let tweet = reponse as! NSDictionary
            success(tweet)
            
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
            print("Error unRetweet!")
        }
    }
}
