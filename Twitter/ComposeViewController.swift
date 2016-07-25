//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Lam Tran on 7/24/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    optional func composeViewController(composeViewController: ComposeViewController, didComposeTweet newTweet: Tweet)
}


class ComposeViewController: UIViewController {

    @IBOutlet weak var userImge: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var replyName: UILabel!
    @IBOutlet weak var replyImage: UIImageView!
    
    @IBOutlet weak var widthReplyImage: NSLayoutConstraint!
    
    @IBOutlet weak var heightReplyImage: NSLayoutConstraint!
    
    @IBOutlet weak var widthName: NSLayoutConstraint!
    
    @IBOutlet weak var heightName: NSLayoutConstraint!
    
    var replyTweet: Tweet?
    weak var delegate: ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TwitterClient.shareInstance.currentAccount({ (user:User) in
            self.userImge.setImageWithURL(user.profileImageUrl!)
            self.userNameLabel.text = user.name
            self.screenNameLabel.text = user.screenName
        }) { (error:NSError) in
            print("Error when get user image \(error.localizedDescription)")
        }
        
        if replyTweet != nil {
            tweetTextView.textColor = UIColor.blackColor()
            
            if let replyNameString = replyTweet?.user?.name {
                replyName.text = "Reply to \(replyNameString)"
                self.navigationItem.title = "Reply Tweet"
            }
            
            if let replyScreeName = replyTweet?.user?.screenName {
                tweetTextView.text = "\(replyScreeName) "
            }
        } else {
            hideReply()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCreateStatus(sender: AnyObject) {
        
        if let replyTweet = replyTweet {
            TwitterClient.shareInstance.replyStatus(tweetTextView.text, originalId: replyTweet.id!, success: { (tweet:Tweet) in
                    print("reply success!")
                    self.delegate?.composeViewController!(self, didComposeTweet: tweet)
                    self.dismissViewControllerAnimated(true, completion: nil)
                
                }, failure: { (error:NSError) in
                print(error.localizedDescription)
            })
        } else {
            TwitterClient.shareInstance.updateStatus(tweetTextView.text, success: { (tweet:Tweet) in
                print("update success!")
                self.delegate?.composeViewController!(self, didComposeTweet: tweet)
                self.dismissViewControllerAnimated(true, completion: nil)
            }) { (error: NSError) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    func hideReply(){
        widthReplyImage.constant = 0
        heightReplyImage.constant = 0
        
        widthName.constant = 0
        heightName.constant = 0
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
