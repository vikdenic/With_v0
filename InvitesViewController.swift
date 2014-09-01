//
//  InvitesViewController.swift
//  With_v0
//
//  Created by Vik Denic on 9/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eventArray : [PFObject] = []
    var eventInviteArray : [PFObject] = []
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        queryForEvents()
    }

    //MARK: Helpers
    func queryForEvents()
    {
        let query = PFQuery(className: "EventInvite")
        query.whereKey("toUser", equalTo: PFUser.currentUser())
        query.whereKey("statusOfUser", equalTo: "Invited")
        query.includeKey("event")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            for object in objects
            {
                self.eventInviteArray.append(object as PFObject)

                let theEvent = object.objectForKey("event") as PFObject
                let eventID = theEvent.objectId

                let eventQuery = PFQuery(className: "Event")
                eventQuery.includeKey("creator")
                eventQuery.whereKey("objectID", equalTo: eventID)
                eventQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    self.eventArray.append(object)
                    self.tableView.reloadData()
                })
            }
        }
    }

    //MARK: Actions
    @IBAction func onDismissTapped(sender: UIBarButtonItem)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func onYesTapped(sender : InvitesButton)
    {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as InvitesTableViewCell

        if sender.imageView.image == UIImage(named: "yes_image_unselected")
        {
            let btnImage = UIImage(named: "yes_image_selected")
            sender.setImage(btnImage, forState: UIControlState.Normal)

            let eventRelation = PFUser.currentUser().relationForKey("eventeAttending")
            eventRelation.addObject(sender.eventObject)
            PFUser.currentUser().saveInBackground()

            sender.eventInviteObject["statusOfUser"] = "Going"
            sender.eventInviteObject.saveInBackground()

            let goingRelation = sender.eventObject.relationForKey("usersAttending")
            goingRelation.addObject(PFUser.currentUser())
            let notGoingRelation = sender.eventObject.relationForKey("usersNotAttending")
            notGoingRelation.removeObject(PFUser.currentUser())
            sender.eventObject.saveInBackground()

            let btnImage2 = UIImage(named: "no_image_unselected")
            cell.noButton.setImage(btnImage2, forState: UIControlState.Normal)
        }

        else if sender.imageView.image == UIImage(named: "yes_image_selected")
        {
            let btnImage = UIImage(named: "yes_image_unselected")
            sender.setImage(btnImage, forState: UIControlState.Normal)

            sender.eventInviteObject["statusOfUser"] = "Invited"
            sender.eventInviteObject.saveInBackground()

            let goingRelation = sender.eventObject.relationForKey("usersAttending")
            goingRelation.removeObject(PFUser .currentUser())
            sender.eventObject.saveInBackground()
        }
    }

    func onNoTapped(sender : InvitesButton)
    {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as InvitesTableViewCell

        if sender.imageView.image == UIImage(named: "no_image_unselected")
        {
            let btnImage = UIImage(named: "no_image_selected")
            sender.setImage(btnImage, forState: UIControlState.Normal)

            let goingRelation = sender.eventObject.relationForKey("usersAttending")
            goingRelation.removeObject(PFUser.currentUser())
            sender.eventObject.saveInBackground()

            sender.eventInviteObject["statusOfUser"] = "Denied"
            sender.eventInviteObject.saveInBackground()

            let notGoingRelation = sender.eventObject.relationForKey("usersNotAttending")
            notGoingRelation.addObject(PFUser.currentUser())
            sender.eventObject.saveInBackground()

            let btnImage2 = UIImage(named: "yes_image_unselected")
            cell.yesButton.setImage(btnImage2, forState: UIControlState.Normal)
        }
        else if sender.imageView.image == UIImage(named: "no_image_selected")
        {
            let btnImage = UIImage(named: "no_image_unselected")
            sender.setImage(btnImage, forState: UIControlState.Normal)

            sender.eventInviteObject["statusOfUser"] = "Invited"
            sender.eventInviteObject.saveInBackground()

            let goingRelation = sender.eventObject.relationForKey("usersNotAttending")
            goingRelation.removeObject(PFUser.currentUser())
            sender.eventObject.saveInBackground()
        }
    }


    //MARK: TableView
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as InvitesTableViewCell
        //TODO: cellForRow
        return cell
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return eventArray.count
    }

}
