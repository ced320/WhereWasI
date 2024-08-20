//
//  PushNotificationManager.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 20.08.24.
//

import SwiftUI
import OSLog

class PushNotificationManager {
    static let logger = Logger()

    static func sendMessage(delayFromNow delay: TimeInterval, title: String, subtitle: String) {
        guard delay >= 0 else {
            logger.warning("Delay was smaller 0. Therefore the push notification was cancelled")
            return
        }
        logger.info("Push notification scheduled: Delay from now: \(delay). Title \(title). Message: \(subtitle).")
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
}


