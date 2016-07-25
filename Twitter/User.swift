//
//  User.swift
//  Twitter
//
//  Created by Lam Tran on 7/19/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = "@\((dictionary["screen_name"] as? String)!)"
        tagline = dictionary["description"] as? String
        
        let profileImageURLString = dictionary["profile_image_url_https"] as? String
        if let profileImageURLString = profileImageURLString {
            profileImageUrl = NSURL(string: profileImageURLString)!
        }
    }
}
