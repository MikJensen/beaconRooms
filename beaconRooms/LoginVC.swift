//
//  LoginVC.swift
//  beaconRooms
//
//  Created by Mik Jensen on 10/3/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAPIManager.getGoogleAPIAuthFromKeychain()
        
        GoogleAPIManager.validateGoogleAPIAuth(self)
        
        if GoogleAPIManager.service.authorizer != nil{
            performSegueWithIdentifier("segueToMainApp", sender: self)
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}

}
