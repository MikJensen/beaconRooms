//
//  SettingsVC.swift
//  beaconRooms
//
//  Created by Mik Jensen on 10/3/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var logoutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutBtn.layer.cornerRadius = 4

        navigationItem.title = "Settings"
    }
    
    @IBAction func logoutPressed(sender: AnyObject) {
        
        performSegueWithIdentifier("unwindToLogin", sender: self)
        GoogleAPIManager.removeGoogleAPIAuthFromKeychain(self)
    }
}
