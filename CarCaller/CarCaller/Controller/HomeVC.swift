//
//  HomeVC.swift
//  CarCaller
//
//  Created by chityuen on 12/20/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RevealingSplashView
import Firebase

class HomeVC: UIViewController{

    @IBOutlet weak var makView: MKMapView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    @IBOutlet weak var ReqLabel: UILabel!
    
    var delegate: CenterVCDelegate?
    
    var manager: CLLocationManager?
    
    let regionRadius: CLLocationDistance = 1000
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "carcallerlunch")!, iconInitialSize:CGSize(width: 80, height: 80) , backgroundColor: UIColor.white)
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthStatus()
        
        makView.delegate = self
        centerMapOnUserLocation()
        
        DataService.instance.REF_DRIVERS.observe(.value, with: {(snapshot) in
            self.loadDriverAnnotationsFromFB()
        })
        
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
        

        

    }
    
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            manager?.startUpdatingLocation()
//            makView.showsUserLocation = true
//            makView.userTrackingMode = .follow
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func loadDriverAnnotationsFromFB(){
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("coordinate"){
                        if driver.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true{
                            if let driverDict = driver.value as? Dictionary<String, AnyObject> {
                                let coordinateArray = driverDict["coordinate"] as! NSArray
                                let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)

                                var driverIsVisible: Bool {
                                    return self.makView.annotations.contains(where: { (annotation) -> Bool in
                                        if let driverAnnotation = annotation as? DriverAnnotation {
                                            if driverAnnotation.key == driver.key {
                                                driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                return true
                                            }
                                        }
                                        return false
                                    })
                                }
                                print("driverIsVisible is \(driverIsVisible)")
                                if !driverIsVisible {
                                    
                                    self.makView.addAnnotation(annotation)
                                }
                            }
                        } else {
                            for annotation in self.makView.annotations {
                                if annotation.isKind(of: DriverAnnotation.self) {
                                    if let annotation = annotation as? DriverAnnotation {
                                        if annotation.key == driver.key {
                                            self.makView.removeAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    func centerMapOnUserLocation(){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(makView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        makView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    @IBAction func BtnPressed(_ sender: Any) {
        ReqLabel.isHidden = true
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
        
    }
    
}

extension HomeVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            makView.showsUserLocation = true
            makView.userTrackingMode = .follow
        }
    }
}

extension HomeVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        }
        return nil
    }
}
