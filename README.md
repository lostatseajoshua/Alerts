[![Twitter: @alvaradojoshua0](https://img.shields.io/badge/contact-@alvaradojoshua0-blue.svg?style=flat)](https://twitter.com/alvaradojoshua0)

# Alerts
Alerts manages displaying UIAlertControllers in succession by coordinating them in a queue.

## Motivation
If you have seen the console log message of:

`Warning: Attempt to present UIAlertController: on viewController: which is already presenting` 

when an alert is presented while there is an active alert displaying, then you understand the case of having a way to coordinate alerts in your application. For an application that heavily relies on alerts, the base implementation of presenting alerts doesn't give enough control. Alerts enables a way to queue up alerts with priority and present your alerts the way you want.

## Requirements
Swift 3.0+
Xcode 8
iOS 8.0+

# Demo 
![Demo of alerts app](https://github.com/lostatseajoshua/Alerts/blob/master/public/alerts.gif)
## How
The project is built on three objects: `Alert`, `AlertAction` and `AlertCoordinator`.

##### AlertCoordinator
Alerts are managed by an `AlertCoordinator` singleton (`AlertCoordinator.main`) which holds three queues based on priority. The queues follow a First In First Out (FIFO) sequence. The coordinator queues up alerts based on priority automatically, can be paused, and told when to display alerts. The coordinator manages three queues internally for high, default and low alerts. The higher priority alerts are dequeued first followed by default then low.

##### Alert
`Alert` is a wrapper class on `UIAlertController` that adds functionality for priority. Apple strictly states to not subclass `UIAlertController` for adding features so the class only holds a `UIAlertController` class within and doesn't subclass it.

##### Alert Priority
An `Alert` class holds a priority for the coordinator to queue the alert correctly. 
###### High
Higher priority alerts are presented first and can also present over lower priority alerts when added to the coordinator if it is actively displaying. If a high priority alert is on display already and another high is added then the waits for the current to be dismissed. 
###### Medium
Medium priority is the default priority and acts like a normal alert. If a higher is priority is added the coordinator will dismiss a default priorty alert and it will be queued up again to be displayed after the higher queue is completed. 
###### Low
Low priority is for alerts that don't need much action and will be dismissed and discarded if another higher priority alert is queued. 

##### AlertAction
`AlertAction` is a wrapper class on `UIAlertAction` that are actions for an `Alert`. The `AlertAction` will notify the `AlertCoordinator` on completion automatically to allow other others to display. Long running actions can be performed on an `AlertAction` that can keep other alerts from displaying until the task is complete. When the task is complete manually call the `complete()` class method to notify the coordinator on the task completion.

## Code Example

#### Simple alert
```swift
let helloWorldAlert = Alert(title: "Hello", message: "World", alertActions: [.defaultAction()]) // .defaultAction() creates a default confirmation AlertAction with a title of Okay
AlertCoordinator.main.enqueue(alert: helloWorldAlert)
AlertCoordinator.main.display()
```
![An alert displaying Hello World message](https://github.com/lostatseajoshua/Alerts/blob/master/public/helloWorldAlert.png)

#### Multiple Alerts

```swift
for i in 0...5 {
    let alert = Alert(title: "\(i)", message: "", alertActions: [.defaultAction()])    
    AlertCoordinator.main.enqueue(alert: alert)
}
AlertCoordinator.main.display() // Alerts from 0 to 5 display in order
```

#### Long running tasks Alert
If you want to display an alert and hold the coordinator from displaying any other alerts until a task is completed.
```swift
let paymentAction = AlertAction(title: "Yes", style: .default, preferred: true, completeOnDismiss: false) { alert in
    // present another view controller for payment and on it's dismissal call AlertAction.complete()
    self.present(paymentVC, animated: true, completion: nil)
}

let alert = Alert(title: "Make a payment", message: "No", alertActions: [.defaultAction()])
alert.actions = [.defaultAction(), paymentAction]
AlertCoordinator.main.enqueue(alert: alert)
AlertCoordinator.main.display()


/// In PaymentViewController.swift
/// completes payment
func completePayment {
    dismiss(animated: true) {
        AlertAction.complete() // Alert Coordinator will begin to display any pending alerts in queue
    }
}
```

#### Priority Alerts
```swift
let high = Alert(title: "High", message: "Message", priority: .high, alertActions: nil)
let medium = Alert(title: "Default", message: "Message", priority: .medium, alertActions: nil)
let low = Alert(title: "Low", message: "Message", priority: .low, alertActions: nil)
```

## Installation

#### Manually
Copy over the `AlertCoordinator.swift` file from the `Alert` folder in the project to your project.

## Contributors
Joshua Alvarado - [Twitter](https://www.twitter.com/alvaradojoshua0)

## License
This project is released under the [MIT license](https://github.com/lostatseajoshua/Alerts/blob/master/LICENSE).
