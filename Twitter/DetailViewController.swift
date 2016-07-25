//
//  DetailViewController.swift
//  Twitter
//
//  Created by Lam Tran on 7/24/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileScreenNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var countFavoriteLabel: UILabel!
    @IBOutlet weak var countReweetLabel: UILabel!
    
    var tweet:Tweet!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImage.setImageWithURL((tweet.user?.profileImageUrl)!)
        profileNameLabel.text = tweet.user?.name
        profileScreenNameLabel.text = tweet.user?.screenName
        tweetLabel.text = tweet.text
        createAtLabel.text = tweet.createdAtShortString
        
        if tweet.isFavorite {
            favoriteButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "like-action"), forState: .Normal)
        }
        
        if tweet.favCount > 0 {
            countFavoriteLabel.text = "\(tweet.favCount!)"
        } else {
            countFavoriteLabel.text = ""
        }
        
        if tweet.isReweeted {
            retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
        }
        
        if tweet.retweetCount > 0 {
            countReweetLabel.text = "\(tweet.retweetCount!)"
        } else {
            countReweetLabel.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRetweet(sender: UIButton) {
        if tweet.isReweeted {
            TwitterClient.shareInstance.getRetweetedId(tweet.id!, success: { (tweet:NSDictionary) in
                let curUserRetweet = tweet["current_user_retweet"] as? NSDictionary
                let retweetId = curUserRetweet!["id"] as? NSNumber
                
                if let myTweetID = retweetId {
                    TwitterClient.shareInstance.unretweet(myTweetID, success: { (reponse: NSDictionary) in
                        self.tweet.isReweeted = false
                        let numberRetweet = self.tweet.retweetCount! - 1
                        self.tweet.retweetCount = numberRetweet
                        if numberRetweet != 0 {
                            self.countReweetLabel.text = "\(numberRetweet)"
                        } else {
                            self.countReweetLabel.text = ""
                        }
                        
                        self.retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
                        
                        }, failure: { (error:NSError) in
                            
                    })
                }
                }, failure: { (error:NSError) in
            })
        } else {
            TwitterClient.shareInstance.retweet(tweet.id!, success: { (reponse: NSDictionary) in
                self.tweet.isReweeted = true
                let numberReweet = self.tweet.retweetCount! + 1
                self.tweet.retweetCount = numberReweet
                self.countReweetLabel.text = "\(numberReweet)"
                self.retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                }, failure: { (error:NSError) in
                    
            })
        }
    }

    
    @IBAction func onFavorite(sender: UIButton) {
        
        if tweet.isFavorite {
            
            TwitterClient.shareInstance.unfavoriteTweet(tweet.id!, success: { (reponse:AnyObject) in
                
                self.tweet.isFavorite = false
                
                let favoriteCount = self.tweet.favCount! - 1
                self.tweet.favCount = favoriteCount
                if favoriteCount != 0 {
                    self.countFavoriteLabel.text = "\(favoriteCount)"
                } else {
                    self.countFavoriteLabel.text = ""
                }
                
                self.favoriteButton.setImage(UIImage(named: "like-action"), forState: .Normal)
                
                }, failure: { (error:NSError) in
                    print("Update favorite error: \(error.localizedDescription)")
            })
        } else {
            TwitterClient.shareInstance.favoriteTweet(tweet.id!, success: { (reponse:AnyObject) in
                self.tweet.isFavorite = true
                let favoriteCount = self.tweet.favCount! + 1
                self.tweet.favCount = favoriteCount
                self.countFavoriteLabel.text = "\(favoriteCount)"
                self.favoriteButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
                }, failure: { (error:NSError) in
                    print("Update favorite error: \(error.localizedDescription)")
            })
        }

        
    }
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationVC = segue.destinationViewController as! UINavigationController
        let composeVC = navigationVC.topViewController as! ComposeViewController
        
        composeVC.replyTweet = tweet
    }
 
    @IBAction func onBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
