//
//  AppDelegate.swift
//  dcidr
//
//  Created by John Smith on 12/26/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

import UserNotifications
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FIRMessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    var mGoogleApiKey: String? = nil
    var mFcmListenerService: FcmListenerService!
    
    func initGoogleServicePlist() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                // use swift dictionary as normal
                self.mGoogleApiKey = dict["API_KEY"] as? String
            }
        }
        
    }
    
    func registerForLocalNotifications(_ application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .sound];
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                // permission not granted
            }else {
                // permission not granted
            }
        }

    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // application requires remote notification registration 
        application.registerForRemoteNotifications()
        
        self.initGoogleServicePlist()
        
        
        // For iOS 10 display notification (sent via APNS)
        //UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        
        // For iOS 10 data message (sent via FCM)
        FIRMessaging.messaging().remoteMessageDelegate = self
        
        self.mFcmListenerService = FcmListenerService.getInstance()
        
        GMSServices.provideAPIKey(self.mGoogleApiKey!)
        GMSPlacesClient.provideAPIKey(self.mGoogleApiKey!)
       
        //self.registerForLocalNotifications(application)
        
        return true
    }
    
    
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        self.mFcmListenerService.handleMessage(ntf: remoteMessage.appData)
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.mFcmListenerService.handleMessage(ntf: userInfo)
    }
    
    

    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.mFcmListenerService.connectToFcm()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        //self.mFcmListenerService.disconnectFcm()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}



