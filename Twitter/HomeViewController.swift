//
//  HomeViewController.swift
//  Twitter
//
//  Created by Lam Tran on 7/19/16.
//  Copyright © 2016 Tan Lam. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ComposeViewControllerDelegate {
    
    @IBOutlet weak var timeLineTabel: UITableView!
    var tweets: [Tweet]!
    var currentRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLineTabel.dataSource = self
        timeLineTabel.delegate = self
        timeLineTabel.estimatedRowHeight = 120
        timeLineTabel.rowHeight = UITableViewAutomaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshTimeLine(_:)), forControlEvents: UIControlEvents.ValueChanged)
        timeLineTabel.insertSubview(refreshControl, atIndex: 0)

        refreshTimeLine(refreshControl)
        }
    
    func refreshTimeLine(refreshControl: UIRefreshControl) {
        
        TwitterClient.shareInstance.homeTimeLine(nil, success: { (tweets:[Tweet]) in
            self.tweets = tweets
            self.timeLineTabel.reloadData()
            refreshControl.endRefreshing()
            
        }) { (error: NSError) in
            print(error.localizedDescription)
            refreshControl.endRefreshing()
        }

    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let navigationVC = segue.destinationViewController as! UINavigationController
        
        if navigationVC.topViewController is ComposeViewController {
            let composeVC = navigationVC.topViewController as! ComposeViewController
            composeVC.delegate = self
            
            if segue.identifier == "replySegue" {
                if let chosenTweetCell = sender!.superview!!.superview as? TwitterHomeTableViewCell {
                    let chosenTweet = chosenTweetCell.tweet
                    composeVC.replyTweet = chosenTweet
                }
            }
        } else if (navigationVC.topViewController is DetailViewController ){
            if(segue.identifier == "DetailSegue"){
                let detailVC = navigationVC.topViewController as! DetailViewController
                detailVC.tweet = tweets[(timeLineTabel.indexPathForSelectedRow?.row)!]
            }
        }
     }
    
    //  Add new tweet after compose
    func composeViewController(composeViewController: ComposeViewController, didComposeTweet newTweet: Tweet) {
        addNewTweet(newTweet)
    }
 
    func addNewTweet(newTweet: Tweet) {
        
        tweets.insert(newTweet, atIndex: 0)
        timeLineTabel.reloadData()
        
        // Scroll to the top of table view
        self.timeLineTabel.contentOffset = CGPointMake(0, 0 - self.timeLineTabel.contentInset.top)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterHomeCell") as! TwitterHomeTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    

    @IBAction func onSignOut(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
