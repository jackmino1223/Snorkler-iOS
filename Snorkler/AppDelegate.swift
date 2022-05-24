//
//  AppDelegate.swift
//  CustomCalloutView
//
//  Created by Malek T. on 3/9/16.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase
import Alamofire
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var timer = Timer()
    var locationManager = CLLocationManager()
    var longitude: String!
    var latitude: String!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        locationManager.requestWhenInUseAuthorization()

        
        FirebaseApp.configure()
        scheduledTimer()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
       
    }

    func scheduledTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sendOnlineRequest), userInfo: nil, repeats: true)
    }
    
    func sendOnlineRequest(){
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorized){
            
            currentLocation = locationManager.location!
            longitude = "\(currentLocation.coordinate.longitude)"
            latitude = "\(currentLocation.coordinate.latitude)"
        }
        
        
        if (UserDefaults.standard.bool(forKey: "isLogedin")){
            
            let parameters = [
                "member_id" : UserDefaults.standard.string(forKey: "memberId") ?? "",
                "isonline" : "1",
                "lat" : latitude as String,
                "lon" : longitude as String
            ]
            
            Alamofire.request("http://54.67.89.86/Snorkler/api/updateOnlineStatus/", method: .post, parameters: parameters).responseJSON { response in
                
            }
            
            
        }
    }
    
    
}

