//
//  AppDelegate.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/12.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseMessaging
import UserNotifications
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let customDataKey = "gcm.notification.customContent"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        
        application.registerForRemoteNotifications()
        
   
        
        // Define identifier
        let notificationName = Notification.Name("NotificationIdentifier")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification), name: notificationName, object: nil)
        
        // Post notification
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        
        if let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            
           
        }
        
        
        initRealm()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    
    func initRealm(){
//        let defaultRealm = try! Realm()
        // Open the realm with a specific file URL, for example a username
        
        
        
        var conf = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "drugs", withExtension: "realm"),
               readOnly: true)
        conf.schemaVersion = 2
        conf.migrationBlock = { (migration, oldSchemaVersion) in
            // nothing to do
            if (oldSchemaVersion < 1) {
                 // Nothing to do!
                 // Realm will automatically detect new properties and removed properties
                 // And will update the schema on disk automatically
               }
        }
        Realm.Configuration.defaultConfiguration = conf
        
        
    }
    @objc dynamic private func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        //        print("\(notification.userInfo?.count ?? 0)")
        //        notification.userInfo.
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        
    }
}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    
    
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        debugPrint("UNUserNotificationCenter willPresent withCompletionHandler")
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print("Handle push from foreground")
        // Print full message.
        print(userInfo)
        
        
        
        if let customData = userInfo[customDataKey] {
            //            print("Message ID: \(messageID)")
            
            
//            if let json = (customData as! String).convertToDictionary {
//
//                debugPrint(json)
//
//
//
//
//            }
            
            
            
        }
        
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Change this to your preferred presentation option
        
        
        completionHandler([.alert, .sound ])
        //        completionHandler([.alert])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("Handle push from background or closed")
        print(response.notification.request.content.userInfo)
        debugPrint("UNUserNotificationCenter didReceive withCompletionHandler")
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print("response.actionIdentifier : \(response.actionIdentifier)")
        
        
        
        
        if let _ = userInfo["aps"] as? [String: AnyObject] {
            
//            if let customData = userInfo[customDataKey] {
//                if let json = (customData as! String).convertToDictionary {
//                    let type = json["type"]   as? String ?? ""
//
//                    let gkey = json["gkey"]   as? String ?? ""
//                    let created = json["created"]   as? String ?? ""
//                    let event = Event(id: -1, type: type, msg: AppConstants.sharedInstance.actionMsg(type: type), gkey: gkey, created: created.convertDate)
////                    showEventDetail(event: event)
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.sharedInstance.recived_log_and_show_detail), object: event, userInfo: userInfo)
//                }
//            }
            
//            let category = aps["category"] as? String
            
            
            
//            if category == AppConstants.sharedInstance.sendChatMessage
//                || category == AppConstants.sharedInstance.logHomet
//                || category == AppConstants.sharedInstance.logMission
//                || category == AppConstants.sharedInstance.logDiet
//                || category == AppConstants.sharedInstance.logBody{
//                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.sharedInstance.sendChatMessage), object: nil, userInfo: userInfo)
//            }else if category == AppConstants.sharedInstance.liveptNow {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.sharedInstance.liveptNow), object: nil, userInfo: userInfo)
//            }
        }
        
        switch response.actionIdentifier {
            
            
        case UNNotificationDefaultActionIdentifier:
            //            self.present()
            
            
            
            
            completionHandler()
            
        default:
            break;
        }
        
        
        // Print full message.
        print(userInfo)
        
    }
    
    
    
}
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(fcmToken)")
//        let dataDict:[String: String] = ["token": fcmToken]
//
//
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        Messaging.messaging().token { token, error in
           // Check for error. Otherwise do what you will with token here
        }
    }
    // [END refresh_token]

    
    
    
}
