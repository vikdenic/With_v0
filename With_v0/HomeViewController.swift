//
//  HomeViewController.swift
//  With_v0
//
//  Created by Vik Denic on 8/28/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

//extension Array{
//    func appendAllObjectsFromArray(array : [AnyObject], arrayWithObjects : [AnyObject]) -> [AnyObject]
//    {
//        for object in arrayWithObjects
//        {
//            array.append(object)
//        }
//        return array
//    }
//}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, PFLogInViewControllerDelegate {

    var event = PFObject(className: "Event")

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

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let currentUser = PFUser.currentUser()

        if currentUser != nil
        {
            queryForEvents()
        }
        else
        {
            var plvc = PFLogInViewController()
            plvc.delegate = self
            presentViewController(plvc, animated: false, completion: nil)
            //            performSegueWithIdentifier("showLogin", sender: self)
        }

//        //pull to refresh
//        refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        tableView.addSubview(refreshControl)

        navigationController.setNavigationBarHidden(false, animated: true)

        let newBackButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
    }

    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        queryForEvents()
        dismissViewControllerAnimated(true, completion: nil)
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

    //MARK: Refresh
    func refresh(refreshControl : UIRefreshControl)
    {
        queryForEvents()
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:  Selector("stopRefresh"), userInfo: nil, repeats: false)
    }

    func stopRefresh()
    {
        refreshControl.endRefreshing()
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
        return self.eventArray.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as HomeTableViewCell

        //TODO: if cell == nil
        let object = eventArray[indexPath.row]

        let queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

        let userProfilePhoto = object.objectForKey("creator").objectForKey("userProfilePhoto") as PFFile

        userProfilePhoto.getDataInBackgroundWithBlock({ (data, error) -> Void in

            if data == nil
            {
                cell.creatorImageView.image = nil
            }
            else
            {
                dispatch_async(queue2, { () -> Void in
                    var temporaryImage = UIImage(data: data)

                    cell.creatorImageView.layer.cornerRadius = cell.creatorImageView.bounds.size.width/2
                    cell.creatorImageView.layer.borderColor = UIColor.greenColor().CGColor
                    cell.creatorImageView.layer.borderWidth = 2.0
                    cell.creatorImageView.layer.masksToBounds = true

                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        cell.creatorImageView.image = temporaryImage
                    })
                })
            }

        })

        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        let file = object.objectForKey("themeImage") as PFFile
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            dispatch_async(queue, { () -> Void in
                var image = UIImage(data: data)

                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    cell.themeImageView.image = image
                })
            })
        }

        let username: AnyObject? = object.objectForKey("creator").objectForKey("username")
        cell.creatorNameLabel.text = "\(username)"

        cell.eventNameLabel.text = object["title"] as String
        cell.eventDateLabel.text = object["eventDate"] as String

        cell.accessoryType = UITableViewCellAccessoryType.None

        let sectionsAmount = tableView.numberOfSections()
        let rowsAmount = tableView.numberOfRowsInSection(indexPath.section)

        if indexPath.section == sectionsAmount - 1 && indexPath.row == rowsAmount - 1
        {
            if !doingTheQuery
            {
                queryForEvents()
            }
        }

        return cell
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        if segue.identifier == "ToPageViewControllerSegue"
        {
            let selectedIndexPath = tableView.indexPathForSelectedRow()
            event = eventArray[selectedIndexPath.row] as PFObject
            let pageViewController = segue.destinationViewController as PageViewController
            pageViewController.event = event
        }
    }
}

































