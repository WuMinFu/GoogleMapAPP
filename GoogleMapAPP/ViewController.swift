//
//  ViewController.swift
//  GoogleMapAPP
//
//  Created by mac on 2018/12/6.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import GoogleMaps


class ViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    var myLocationMgr: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationMgr = CLLocationManager()
        myLocationMgr.delegate = self
        myLocationMgr.requestWhenInUseAuthorization() // request user authorize
        myLocationMgr.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        myLocationMgr.desiredAccuracy = kCLLocationAccuracyBest

        
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Get user author
        switch status {
        case .authorizedWhenInUse:
            myLocationMgr.startUpdatingLocation() // Start location
            mapView.isMyLocationEnabled = true
            
            mapView.settings.myLocationButton = true
            
        case .denied:
            let alertController = UIAlertController(title: "定位權限已關閉", message:"如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[0] as CLLocation
        print("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        if let location = locations.first {

            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 18)
            myLocationMgr.stopUpdatingLocation()
        }
    }

    @IBAction func getAddress(_ sender: Any) {
        print("Current Location: \(mapView.layer.cameraLatitude), \(mapView.layer.cameraLongitude)")
        
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: mapView.layer.cameraLatitude, longitude: mapView.layer.cameraLongitude)
        
        let locale = Locale(identifier: "zh_TW")
        if #available(iOS 11.0, *) {
            ceo.reverseGeocodeLocation(loc, preferredLocale: locale) {
                (placemarks, error) in
                if error == nil {
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.subAdministrativeArea ?? "")
                        print(pm.locality ?? "")
                        print(pm.name ?? "")
                    }
                }
            }
        }else {
            UserDefaults.standard.set(["zh_TW"], forKey: "AppleLanguages")
            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                    if error == nil {
                        let pm = placemarks! as [CLPlacemark]
                        if pm.count > 0 {
                            let pm = placemarks![0]
                            print(pm.subAdministrativeArea ?? "")
                            print(pm.locality ?? "")
                            print(pm.name ?? "")
                        }
                    }
            })
        }
    }
}

