//
//  TwitterHomeTableViewCell.swift
//  Twitter
//
//  Created by Lam Tran on 7/24/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

class TwitterHomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var twitterText: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var reweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var numberRetweet: UILabel!
    @IBOutlet weak var numberFavorite: UILabel!
    
    var tweet:Tweet! {
        didSet {
            profileImage.setImageWithURL((tweet.user?.profileImageUrl)!)
            userNameLabel.text = tweet.user?.name
            screenNameLabel.text = tweet.user?.screenName
            createTimeLabel.text = tweet.timeSinceCreated
            twitterText.text = tweet.text
            
            if let countRetweet = tweet.retweetCount {
                if countRetweet > 0 {
                    numberRetweet.text = "\(countRetweet)"
                } else {
                    numberRetweet.text = ""
                }
            }
            
            if let countFavorite = tweet.favCount {
                if countFavorite > 0 {
                    numberFavorite.text = "\(countFavorite)"
                } else {
                    numberFavorite.text = ""
                }
            }
            
            //  Set icon for retweet
            if tweet.isReweeted {
                reweetButton.setBackgroundImage(UIImage(named: "retweet-action-on"), forState: .Normal)
            } else {
                reweetButton.setBackgroundImage(UIImage(named: "retweet-action"), forState: .Normal)
            }
            
            //  Set icon for favorite
            if tweet.isFavorite {
                favoriteButton.setBackgroundImage(UIImage(named: "like-action-on"), forState: .Normal)
            } else {
                favoriteButton.setBackgroundImage(UIImage(named: "like-action"), forState: .Normal)
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onReply(sender: AnyObject) {
    }
    
    @IBAction func onRetweet(sender: UIButton) {
        if let selectedTweetCell = sender.superview?.superview as? TwitterHomeTableViewCell {
            let selectedTweet = selectedTweetCell.tweet
            
            if selectedTweet.isReweeted {
                TwitterClient.shareInstance.getRetweetedId(selectedTweet.id!, success: { (tweet:NSDictionary) in
                    let curUserRetweet = tweet["current_user_retweet"] as? NSDictionary
                    let retweetId = curUserRetweet!["id"] as? NSNumber
                    
                    if let myTweetID = retweetId {
                        TwitterClient.shareInstance.unretweet(myTweetID, success: { (reponse: NSDictionary) in
                            selectedTweet.isReweeted = false
                            let numberRetweet = selectedTweet.retweetCount! - 1
                            selectedTweet.retweetCount = numberRetweet
                            if numberRetweet != 0 {
                                self.numberRetweet.text = "\(numberRetweet)"
                            } else {
                                self.numberRetweet.text = ""
                            }
                            
                            self.reweetButton.setBackgroundImage(UIImage(named: "retweet-action"), forState: .Normal)
                            
                            }, failure: { (error:NSError) in
                                
                        })
                    }
                    }, failure: { (error:NSError) in
                })
            } else {
                TwitterClient.shareInstance.retweet(selectedTweet.id!, success: { (reponse: NSDictionary) in
                    selectedTweet.isReweeted = true
                    let numberReweet = selectedTweet.retweetCount! + 1
                    selectedTweet.retweetCount = numberReweet
                    self.numberRetweet.text = "\(numberReweet)"
                    self.reweetButton.setBackgroundImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                    }, failure: { (error:NSError) in
                        
                })
            }
            
        }
        
    }
    
    
    @IBAction func onFavorite(sender: UIButton) {
        if let selectedTweetCell = sender.superview?.superview as? TwitterHomeTableViewCell {
            let selectedTweet = selectedTweetCell.tweet

            if selectedTweet.isFavorite {
                
                TwitterClient.shareInstance.unfavoriteTweet(selectedTweet.id!, success: { (reponse:AnyObject) in
                    
                        selectedTweet.isFavorite = false
                        
                        let favoriteCount = selectedTweet.favCount! - 1
                        selectedTweet.favCount = favoriteCount
                        if favoriteCount != 0 {
                            self.numberFavorite.text = "\(favoriteCount)"
                        } else {
                            self.numberFavorite.text = ""
                        }
                        
                        self.favoriteButton.setBackgroundImage(UIImage(named: "like-action"), forState: .Normal)
                    
                    }, failure: { (error:NSError) in
                    print("Update favorite error: \(error.localizedDescription)")
                })
            } else {
                TwitterClient.shareInstance.favoriteTweet(selectedTweet.id!, success: { (reponse:AnyObject) in
                    selectedTweet.isFavorite = true
                    let favoriteCount = selectedTweet.favCount! + 1
                    selectedTweet.favCount = favoriteCount
                    self.numberFavorite.text = "\(favoriteCount)"
                    self.favoriteButton.setBackgroundImage(UIImage(named: "like-action-on"), forState: .Normal)
                    }, failure: { (error:NSError) in
                          print("Update favorite error: \(error.localizedDescription)")
                })
            }
        }

    }
    
}
