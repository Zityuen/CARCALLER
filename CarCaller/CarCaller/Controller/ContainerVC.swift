//
//  ContainerVC.swift
//  CarCaller
//
//  Created by chityuen on 12/20/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case collaspsed
    case leftPanelExpanded
}

enum ShowWhichVC {
    case homeVC
}

var showVC: ShowWhichVC = .homeVC

class ContainerVC: UIViewController {

    var homeVC: HomeVC!
    var leftVC: LeftSidePanelVC!
    var centerController: UIViewController!
    var currentState: SlideOutState = .collaspsed {
        didSet {
            let shouldShowShadow = (currentState != .collaspsed)
            
            shouldShowShadowForCenterVC(shouldShowShadow)
        }
    }
    
    var isHidden = false
    let centerPanelExpandedOffset: CGFloat = 160
    
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCenter(screen: showVC)
    }
    
    func initCenter(screen: ShowWhichVC){
        var presentingController: UIViewController
        
        showVC = screen
        
        if homeVC == nil {
            homeVC = UIStoryboard.homeVC()
            homeVC.delegate = self
        }
        
        presentingController = homeVC
        
        if let con = centerController {
            con.view.removeFromSuperview()
            con.removeFromParentViewController()
        }
        
        centerController = presentingController
        
        view.addSubview(centerController.view)
        addChildViewController(centerController)
        centerController.didMove(toParentViewController: self)
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool{
        return isHidden
    }
}

extension ContainerVC: CenterVCDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded{
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    func addLeftPanelViewController() {
        if leftVC == nil{
            leftVC = UIStoryboard.leftViewController()
            addChildSidePanelViewController(leftVC)
        }
    }
    func addChildSidePanelViewController(_ sidePanelController: LeftSidePanelVC){
        view.insertSubview(sidePanelController.view, at: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    @objc func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            isHidden = !isHidden
            
            animateStatusBar()
            setupWhiteCoverView()
            currentState = .leftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: centerController.view.frame.width - centerPanelExpandedOffset)
            
        } else {
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            animateCenterPanelXPosition(targetPosition: 0, completion: { (finished) in
                if finished {
                    self.currentState = .collaspsed
                    self.leftVC = nil
                }
            })
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat,  completion: ((Bool)-> Void)! = nil){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func setupWhiteCoverView(){
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = UIColor.white
        whiteCoverView.tag = 25
        
        self.centerController.view.addSubview(whiteCoverView)
        whiteCoverView.fadeTo(alphaValue: 0.75, withDuration: 0.2)

        
        tap = UITapGestureRecognizer(target: self, action:  #selector(animateLeftPanel(shouldExpand: )))
        tap.numberOfTapsRequired = 1
        
        self.centerController.view.addGestureRecognizer(tap)
    }
    
    func hideWhiteCoverView() {
        centerController.view.removeGestureRecognizer(tap)
        for subview in self.centerController.view.subviews {
            if subview.tag == 25{
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }, completion: { (_) in
                    subview.removeFromSuperview()
                })
            }
        }
    }
    
    func shouldShowShadowForCenterVC(_ status: Bool){
        if status == true {
            centerController.view.layer.shadowOpacity = 0.6
        } else {
            centerController.view.layer.shadowOpacity = 0.0
        }
    }
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
}

private extension UIStoryboard {
    class func mainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func leftViewController() -> LeftSidePanelVC? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "LeftVC") as? LeftSidePanelVC
    }
    
    class func homeVC() -> HomeVC? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
    }
}
