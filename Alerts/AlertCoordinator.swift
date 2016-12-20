//
//  AlertCoordinator.swift
//  Alerts
//
//  Created by Joshua Alvarado on 6/1/16.
//  Copyright © 2016 Joshua Alvarado. All rights reserved.
//

import Foundation
import UIKit

/// Coordinator for displaying multiple alerts to the foreground. Only one alert can display at any given time. The `AlertCoordinator` queues the alerts to display them after activity
class AlertCoordinator: NSObject {
    private(set) var highPriorityQueue = [Alert]()
    private(set) var defaultPriorityQueue = [Alert]()
    private(set) var lowPriorityQueue = [Alert]()
    private(set) var paused = false

    private weak var currentDisplayingAlert: Alert? = nil
    
    static let main = AlertCoordinator()
    
    /// Push an alert to the queue
    func enqueue(alert: Alert, atIndex index: Int? = nil) {
        switch alert.prority {
        case .high:
            highPriorityQueue.insert(alert, at: index ?? highPriorityQueue.endIndex)
        case .medium:
            defaultPriorityQueue.insert(alert, at: index ?? defaultPriorityQueue.endIndex)
        case .low:
            lowPriorityQueue.insert(alert, at: index ?? lowPriorityQueue.endIndex)
        }
    }
    
    func display() {
        if !paused {
            dequeueAlert()
        }
    }
    
    func pause() {
        paused = true
    }
    
    func reset() {
        removeCurrentDisplayingAlert(force: true, completion: nil)
        highPriorityQueue.removeAll()
        defaultPriorityQueue.removeAll()
        lowPriorityQueue.removeAll()
    }
    
    fileprivate func onCurrentAlertDismissed() {
        currentDisplayingAlert = nil
        display()
    }
    
    private func nextAlert() -> Alert? {
        if !highPriorityQueue.isEmpty {
            return highPriorityQueue.removeFirst()
        }
        
        if !defaultPriorityQueue.isEmpty {
            return defaultPriorityQueue.removeFirst()
        }
        
        if !lowPriorityQueue.isEmpty {
            return lowPriorityQueue.removeFirst()
        }
        
        return nil
    }
    
    /// Pop an alert off of the queue and display if it can
    private func dequeueAlert() {
        guard let alert = nextAlert() else {
            return
        }
        
        removeCurrentDisplayingAlert(force: false) {
            if let dismissedAlert = $0 {
                self.putBack(dismissedAlert)
                self.present(alert)
            } else {
                self.present(alert)
            }
        }
    }
    
    private func removeCurrentDisplayingAlert(force: Bool, completion: ((Alert?) -> Void)?) {
        guard let currentDisplayingAlert = currentDisplayingAlert else {
            completion?(nil)
            return
        }
        
        if force || currentDisplayingAlert.dismissable {
            currentDisplayingAlert.dismiss(true) {
                completion?(currentDisplayingAlert)
            }
        }
    }
    
    private func putBack(_ alert: Alert) {
        enqueue(alert: alert, atIndex: 0)
    }
    
    private func present(_ alert: Alert) {
        // present alert in it's on UIWindow
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert.alertController, animated: true) {
            self.currentDisplayingAlert = alert
        }
    }
}

/// Class to construct an alert to be queued for the `AlertCoordinator` to present. Alert adds prority to have high alerts dismiss lower priorty alerts and queue them for a later time.
class Alert {
    let title: String?
    let message: String?
    let prority: Priorty
    var actions: [AlertAction]?
    
    fileprivate var dismissable: Bool {
        return prority != .high
    }
    
     lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        
        // loop through actions and add to alert controller
        if let actions = self.actions {
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style, handler: action.actionHandler)
                
                alertController.addAction(alertAction)
                
                if action.preferred {
                    // set preferred action after action has been added
                    if #available(iOS 9.0, *) {
                        alertController.preferredAction = alertAction
                    }
                }
            }
        }
        
        return alertController
    }()
    
    enum Priorty {
        case high
        /// Default priorty
        case medium
        case low
    }
    
    init(title: String?, message: String?, priorty: Priorty = .low, alertActions: [AlertAction]?) {
        self.title = title
        self.message = message
        self.prority = priorty
        
        self.actions = alertActions
    }
    
    func dismiss(_ animated: Bool, completion: (() -> Void)?) {
        alertController.dismiss(animated: true, completion: completion)
    }
}

/// Constructor for an action to give to an `Alert` class
/// - important: fire `AlertAction.complete()` when your custom action handler is complete
struct AlertAction {
    let title: String
    let style: UIAlertActionStyle
    var actionHandler: ((UIAlertAction) -> Void)?
    let preferred: Bool

    init(title: String, style: UIAlertActionStyle, preferred: Bool = false, completeOnDismiss: Bool = true, actionHandler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.preferred = preferred
        self.actionHandler = { action in
            actionHandler?(action)
            if completeOnDismiss {
                AlertAction.complete()
            }
        }
    }
    
    /// Completes the Alert Action and notifies the `AlertCoordinator` of the completed action
    static func complete() {
        AlertCoordinator.main.onCurrentAlertDismissed()
    }
}
