//
//  AlertCoordinator.swift
//  Alerts
//
//  Created by Joshua Alvarado on 6/1/16.
//  Copyright © 2016 Joshua Alvarado. All rights reserved.
//

import Foundation
import UIKit

/**
 The AlertCoordinator class is used to enqueue `Alert`s to display. The `main` instance of this class is to be used.
 
 The AlertCoorinator enqueues `Alert` type instances to display by enqueuing each by priority. The alerts are placed in a First In First Out collection organized by the alert's priority property.
 
 To use this class enqueue the alerts desired and then call the `display` method to begin the process of displaying the alerts. Use the `pause` method to temporarily hold back alerts from displaying. To tear down the class call the `reset` method and the queue will be emptied.
 */
class AlertCoordinator: NSObject {
    private(set) var highPriorityQueue = [Alert]()
    private(set) var defaultPriorityQueue = [Alert]()
    private(set) var lowPriorityQueue = [Alert]()
    private(set) var paused = false
 
    private weak var currentDisplayingAlert: Alert? = nil
    
    static let main = AlertCoordinator()
    
    /// Push an alert to the queue
    func enqueue(alert: Alert, atIndex index: Int? = nil) {
        switch alert.priority {
        case .high:
            highPriorityQueue.insert(alert, at: index ?? highPriorityQueue.endIndex)
        case .medium:
            defaultPriorityQueue.insert(alert, at: index ?? defaultPriorityQueue.endIndex)
        case .low:
            lowPriorityQueue.insert(alert, at: index ?? lowPriorityQueue.endIndex)
        }
    }
    
    /// Show alerts if any are available and the cooridnator is not paused.
    func display() {
        if !paused {
            dequeueAlert()
        }
    }
    
    func pause() {
        paused = true
    }
    
    /// Dismiss any actively displaying alert and remove all from the queue.
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
        // present alert in a new UIWindow
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert.alertController, animated: true) {
            self.currentDisplayingAlert = alert
        }
    }
    
    override var description: String {
        let displaying: String
        
        if currentDisplayingAlert != nil {
            displaying = "is displaying"
        } else {
            displaying = "is not displaying"
        }
        let numOfAlert = highPriorityQueue.count + defaultPriorityQueue.count + lowPriorityQueue.count
        
        
        return "Alert Coordinator is " + displaying + "an alert with \(numOfAlert) alerts queued."
    }
    
    override var debugDescription: String {
        let displaying: String
        
        if currentDisplayingAlert != nil {
            displaying = "is displaying"
        } else {
            displaying = "is not displaying"
        }
        
        return "Alert Coordinator is " + displaying + "an alert with \(highPriorityQueue.count) hight alerts, \(defaultPriorityQueue.count) default alerts, and \(lowPriorityQueue.count) low alerts queued."
    }
}

/**
 An `Alert` is an object that hanldes a `UIAlertController` with added features. This class replaces the direct use of `UIAlertContoller`. With an instance of this class display it by enqueueing to an instance of an `AlertCoordinator`.
 */
class Alert {
    let title: String?
    let message: String?
    let priority: Priority
    let style: UIAlertControllerStyle
    var actions = [AlertAction]()
    
    fileprivate var dismissable: Bool {
        return priority != .high
    }
    
    lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: self.style)
        
        // loop through actions and add to alert controller
        if !self.actions.isEmpty {
            for action in self.actions {
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
    
    enum Priority {
        case high
        /// Default priorty
        case medium
        case low
    }
    
    /**
     Creates and returns an Alert to be used by an `AlertCoordinator`.
     After creating the Alert actions can be added by appending to the `actions` property.
     - parameters:
        - title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
        - message: descriptive text that provides additional details about the reason for the alert.
        - priority: The level of urgency of the alert.
        - style: The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
        - alertActions: Adds actions
    */
    init(title: String?, message: String?, priority: Priority = .medium, style: UIAlertControllerStyle = .alert, alertActions: [AlertAction]?) {
        self.title = title
        self.message = message
        self.priority = priority
        if let actions = alertActions {
            self.actions = actions
        }
        self.style = style
    }
    
    /**
     Dismiss the alert. Calling dismiss on the `alertController` property will give the same result but this method adds the completion of the alert action to keep the AlertCoordinator in sync.
     - parameters:
        - animated: Pass `true` to animate the transition.
        - completion: The block to execute after the alert is dismissed. This block has no return value and takes no parameters. You may specify nil for this parameter.
     - important: it is important to call `AlertAction.complete()` on manual of an alert to keep the AlertCoordinator in sync when not using this method. This method does it automatically on completion.
     */
    func dismiss(_ animated: Bool, completion: (() -> Void)?) {
        alertController.dismiss(animated: true, completion: completion)
    }
}

/**
 The object for encapsulating an action to add to an `Alert`.
 
 Alert Actions coordinate the completion of their task to the main `AlertCoordinator` so that other alerts can display when the encapsulating alert is done running its work. This is done automatically for actions. It can be done manually if finer control is needed for actions that take more time. To manually control the process by initializing an `AlertAction` with false in the `completeOnDismiss` parameter and call `AlertAction.complete()` wherever the alert action completes. If the `AlertCoordinator` can continue to display alerts (not paused and more alerts are queued) then the coordinator will continue to display alerts after the `complete` call.
 - important: fire `AlertAction.complete()` when your custom action handler is complete on escaping long running tasks
 */
struct AlertAction {
    let title: String
    let style: UIAlertActionStyle
    private(set) var actionHandler: ((UIAlertAction) -> Void)?
    let preferred: Bool
    
    /**
     Creates an instance of an `AlertAction` to be added to an `Alert`
     - parameters:
        - title: The text to use for the button title. The value you specify should be localized for the user’s current language. This parameter must not be nil, except in a tvOS app where a nil title may be used with cancel.
        - style: Additional styling information to apply to the button. Use the style information to convey the type of action that is performed by the button. For a list of possible values, see the constants in UIAlertActionStyle.
        - preferred: The preferred action for the user to take from an alert. *NOTE: Only available on iOS 9+
        - completeOnDismiss: `true` to call `complete` automatically on the action completion. `false` to not add the complete on the action.
        - actionHandler: A block to execute when the user selects the action. This block has no return value and takes the selected action-object as its only parameter.
     */
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
    
    /**
     Completes a manual Alert action
     
     The `AlertCoordinator` will display alerts after if any are queued and the coordinator is not paused.
     */
    static func complete() {
        AlertCoordinator.main.onCurrentAlertDismissed()
    }
    
    /**
     Creates a default confirmation `AlertAction` with a title of Okay.
     - parameter preferred: `true` sets the default action preferred *NOTE: Only available on iOS 9+
     - returns: An AlertAction with default style
     */
    static func defaultAction(preferred: Bool = false) -> AlertAction {
        return AlertAction(title: "Okay", style: .default, preferred: preferred)
    }
}
