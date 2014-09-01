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

        let object = eventArray[indexPath.row]
        let eventInvite = eventInviteArray[indexPath.row]

        let userProfilePhoto = object.objectForKey("creator").objectForKey("userProfilePhoto") as PFFile
        userProfilePhoto.getDataInBackgroundWithBlock { (data, error) -> Void in
            if data == nil
            {
                cell.creatorImageView.image = nil
            }
            else
            {
                let temporaryImage = UIImage(data: data)
                cell.creatorImageView.layer.cornerRadius = cell.creatorImageView.bounds.size.width/2
                cell.creatorImageView.layer.borderColor = UIColor.greenColor().CGColor
                cell.creatorImageView.layer.borderWidth = 2.0
                cell.creatorImageView.layer.masksToBounds = true
                cell.creatorImageView.image = temporaryImage
            }
        }

        let file = object.objectForKey("themeImage") as PFFile
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            let image = UIImage(data: data)
            cell.themeImageView.image = image
        }

        let userName = object.objectForKey("creator").objectForKey("username") as String
        cell.creatorNameLabel.text = userName

        cell.eventNameLabel.text = object["title"] as String
        cell.eventDateLabel.text = object["eventDate"] as String
        cell.accessoryType = UITableViewCellAccessoryType.None

        let yesButton = UIImage(named: "yes_image_unselected")
        cell.yesButton.setImage(yesButton, forState: UIControlState.Normal)
        cell.yesButton.eventObject = object
        cell.yesButton.tag = indexPath.row
        cell.yesButton.eventInviteObject = eventInvite
        cell.yesButton.addTarget(self, action: "onYesTapped", forControlEvents: UIControlEvents.TouchUpInside)

        let noButton = UIImage(named: "no_image_unselected")
        cell.noButton.setImage(noButton, forState: UIControlState.Normal)
        cell.noButton.eventObject = object
        cell.noButton.eventInviteObject = eventInvite
        cell.noButton.tag = indexPath.row
        cell.noButton.addTarget(self, action: "onNoTapped", forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return eventArray.count
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
