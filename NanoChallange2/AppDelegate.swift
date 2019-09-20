//
//  AppDelegate.swift
//  NanoChallange2
//
//  Created by Hai on 18/09/19.
//  Copyright © 2019 Asep Abdaz. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager : CLLocationManager = CLLocationManager()

    enum AuthenticationsState {
        case loggedin, loggedout
    }
    
    var context = LAContext()
    
    var state = AuthenticationsState.loggedout{
        didSet{
            state == .loggedin
            (state == .loggedin) || (context.biometryType != .faceID)
            
        }
    }
    
    func check() {
        
        if state == .loggedin {
            // logout saja
            state = .loggedout
        }else{
            context = LAContext()
            
            
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Log inb to your account"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.state = .loggedin
//                            self.performSegue(withIdentifier: "sukses", sender: nil)
                        }
                    }else{
                        print(error?.localizedDescription ?? "Can't evaluate policy")
                    }
                }
            }
        }
        
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
        }

        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
//        check()
    }
    func handleEvent(for region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            guard let body = note(from: region.identifier) else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.title = "Roar"
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    func note(from identifier: String) -> String? {
        let geotifications = Geotification.allGeotifications()
        guard let matched = geotifications.filter({
            $0.identifier == identifier
        }).first else { return nil }
        return matched.note
    }
}
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
}


