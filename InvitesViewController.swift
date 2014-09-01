//
//  InvitesViewController.swift
//  With_v0
//
//  Created by Vik Denic on 9/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        //TODO: numberOfRows
        return 1
    }
    
}
