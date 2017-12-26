//
//  LeftSidePanelVC.swift
//  CarCaller
//
//  Created by chityuen on 12/20/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit
import Firebase


class LeftSidePanelVC: UIViewController {

    let appDelegate = AppDelegate.getAppDelegat()
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userAccountTypeLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userImageVIew: RoundImageView!
    @IBOutlet weak var pickupModeSwitch: UISwitch!
    @IBOutlet weak var pickupModeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickupModeSwitch.isOn = false
        pickupModeLbl.isHidden = true
        pickupModeSwitch.isHidden = true
        userAccountTypeLbl.text = ""
        
        observePassengersAndDrivers()
        if Auth.auth().currentUser == nil {
            userEmailLbl.text = ""
//            userAccountTypeLbl = ""
            userImageVIew.isHidden = true
            loginBtn.setTitle("Sign Up / Login", for: .normal)
        } else {
            userEmailLbl.text = Auth.auth().currentUser?.email
            userImageVIew.isHidden = false
            loginBtn.setTitle("LogOut", for: .normal)
        }
    }
 
    func observePassengersAndDrivers(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {

                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid{
                        self.userAccountTypeLbl.text = "Passenger"
                    }
                }
            }
        })
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid{
                        self.userAccountTypeLbl.text = "Driver"
                        self.pickupModeSwitch.isHidden = false
                        
                        let switchStatus = snap.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
                        self.pickupModeSwitch.isOn = switchStatus
                        self.pickupModeLbl.isHidden = false
                    }
                }
            }
        })
    }
    @IBAction func switchWasToggled(_ sender: Any) {
        if pickupModeSwitch.isOn {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                self.appDelegate.MenuContainerVC.toggleLeftPanel()
            })
            
            
            
            DataService.instance.REF_DRIVERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["isPickupModeEnabled": true])
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                self.appDelegate.MenuContainerVC.toggleLeftPanel()
            })
            DataService.instance.REF_DRIVERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["isPickupModeEnabled": false])
        }
    }
    
    @IBAction func LoginBtnPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            present(loginVC, animated: true, completion: nil)
        } else {
            do {
                DataService.instance.REF_DRIVERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["isPickupModeEnabled": false])
                try Auth.auth().signOut()
                userImageVIew.isHidden = true
                userEmailLbl.text = ""
                userAccountTypeLbl.text = ""
                pickupModeLbl.isHidden = true
                pickupModeSwitch.isHidden = true
                loginBtn.setTitle("Sign Up / Login", for: .normal)
            } catch {
                print(error)
            }
        }
        
    }
}
