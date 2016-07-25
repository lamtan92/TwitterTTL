//
//  Tweet.swift
//  Twitter
//
//  Created by Lam Tran on 7/19/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: NSNumber?
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAtShortString: String?
    var createdAt: NSDate?
    var timeSinceCreated: String?
    
    var retweetCount: Int?
    var favCount: Int?
    var isReweeted = false
    var isFavorite = false
    
    var retweet: Tweet?
    
    var replyToStatusID: NSNumber?
    var replyToScreenName: String?
    
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? NSNumber!
        
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        
        createdAtString = dictionary["created_at"] as? String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        createdAtShortString = formatter.stringFromDate(createdAt!)
        
        let elapsedTime = NSDate().timeIntervalSinceDate(createdAt!)
        if elapsedTime < 60 {
            timeSinceCreated = String(Int(elapsedTime)) + "s"
        } else if elapsedTime < 3600 {
            timeSinceCreated = String(Int(elapsedTime / 60)) + "m"
        } else if elapsedTime < 24*3600 {
            timeSinceCreated = String(Int(elapsedTime / 60 / 60)) + "h"
        } else {
            timeSinceCreated = String(Int(elapsedTime / 60 / 60 / 24)) + "d"
        }
        
        
        retweetCount = (dictionary["retweet_count"] as? Int)!
        favCount = (dictionary["favorite_count"] as? Int)!
        isReweeted = (dictionary["retweeted"] as? Bool)!
        isFavorite = (dictionary["favorited"] as? Bool)!
        
        if let retweetDictionary = dictionary["retweeted_status"] as? NSDictionary {
            retweet = Tweet(dictionary: retweetDictionary)
        }

    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dict in array {
            tweets.append(Tweet(dictionary: dict))
        }
        return tweets
    }
    
    func formatedDetailDate(dateCreated:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let dateString = dateFormatter.stringFromDate(dateCreated)
        
        return dateString
    }
}
