//
//  HomeVC.swift
//  CarCaller
//
//  Created by chityuen on 12/20/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView

class HomeVC: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var makView: MKMapView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    @IBOutlet weak var ReqLabel: UILabel!
    
    var delegate: CenterVCDelegate?
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "carcallerlunch")!, iconInitialSize:CGSize(width: 80, height: 80) , backgroundColor: UIColor.white)
    override func viewDidLoad() {
        super.viewDidLoad()
        makView.delegate = self
        
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        
        revealingSplashView.heartAttack = true
    }

    @IBAction func BtnPressed(_ sender: Any) {
        
//        self.actionBtn.setTitle("22", for: .normal)
        ReqLabel.isHidden = true
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
        
    }
    
}



