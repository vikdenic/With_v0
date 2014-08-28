//
//  HomeViewController.swift
//  With_v0
//
//  Created by Vik Denic on 8/28/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

//extension Array{
//    func appendAllObjectsFromArray(array : [AnyObject]) -> [AnyObject]
//    {
//        for object in array
//        {
//            array.append(object)
//        }
//
//        return array
//    }
//}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {

    var event = PFObject()

    @IBOutlet var tableView: UITableView!

    var refreshControl = UIRefreshControl()

    var eventArray : [PFObject] = []
    var indexPathArray : [NSIndexPath] = []
    var doingTheQuery = Bool()

    var originalFrame = CGRect()

    var startContentOffset = CGFloat()
    var lastContentOffset = CGFloat()
    var hidden = Bool()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        tabBarController.tabBar.hidden = false;
        originalFrame = tabBarController.tabBar.frame
        tabBarController.tabBar.tintColor = UIColor.greenColor()

        let currentUser = PFUser.currentUser()

        if currentUser != nil
        {
            queryForEvents()
        }
        else
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }

        //pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        navigationController.setNavigationBarHidden(false, animated: true)

        let newBackButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
    }

    //MARK: Helpers
    func queryForEvents()
    {
        let relation = PFUser.currentUser().relationForKey("eventsAttending")
        let query = relation.query()
        query.includeKey("creator")
        query.limit = 4

        if eventArray.count == 0
        {
            query.skip = 0
        }
        else{
            query.skip = eventArray.count
        }

        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in

            self.doingTheQuery = true

            if self.eventArray.count < 3
            {
                self.eventArray = objects as [PFObject]
                self.tableView.reloadData()
            }
            else if self.eventArray.count >= 3
            {
                var theCount = self.eventArray.count
                self.eventArray = objects as [PFObject]

                for var i = theCount; i <= self.eventArray.count-1; i++
                {
                    var indexPath = NSIndexPath(forRow: i, inSection: 0)
                    self.indexPathArray.append(indexPath)
                }

                self.tableView.insertRowsAtIndexPaths(self.indexPathArray, withRowAnimation: UITableViewRowAnimation.Fade)
                self.indexPathArray.removeAll(keepCapacity: false)
                self.tableView.reloadData()
            }
            self.doingTheQuery = false
        }
    }


    //MARK: Notif Center
    func receiveNotification(notification : NSNotification)
    {
        if notification.name == "Test1"
        {
            eventArray.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }

    //MARK: TableView
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as HomeTableViewCell

        return cell
    }

    //MARK: Hide TabBar
    func expand()
    {
        if hidden
        {
            return
        }

        hidden = false;
        tabBarController.setTabBarHidden(false, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }

    func contract()
    {
        if !hidden
        {
            return
        }

        hidden = false

        tabBarController.setTabBarHidden(false, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView!)
    {
        startContentOffset = lastContentOffset
        lastContentOffset = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(scrollView: UIScrollView!)
    {
        var currentOffset = scrollView.contentOffset.y
        var differenceFromStart = startContentOffset - currentOffset
        var differenceFromLast = lastContentOffset - currentOffset
        lastContentOffset = currentOffset

        if differenceFromStart < 0
        {
            if scrollView.tracking && abs(differenceFromLast) > 1
            {
                expand()
            }
            else
            {
                if scrollView.tracking && abs(differenceFromLast)>1
                {
                    contract()
                }
            }
        }
    }

    func scrollViewShouldScrollToTop(scrollView: UIScrollView!) -> Bool
    {
        contract()
        return true
    }




}

































