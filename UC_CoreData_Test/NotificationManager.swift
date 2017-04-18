//
//  NotificationManager.swift
//  UC_CoreData_Test
//
//  Created by John Barbone on 2/28/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UserNotifications

let center = UNUserNotificationCenter.current()

class NotificationsManager {
    
    let center = UNUserNotificationCenter.current()
    
    init() {
        center.requestAuthorization(options: UNAuthorizationOptions.alert) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    
    
    func newNotification(med: String, mph: Int32) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "It's time to take \(med)!"
        content.body = "this is a content body CHANGE IT CHANGE IT CHANGE IT"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(mph)*Double(3600), repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    
}
