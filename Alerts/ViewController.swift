//
//  ViewController.swift
//  Alerts
//
//  Created by Joshua Alvarado on 8/29/16.
//  Copyright © 2016 Joshua Alvarado. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dispatchAction = AlertAction(title: "Dispatch", style: .default, preferred: true, completeOnDismiss: false) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AlertAction.complete()
            }
        }
        
        let actionSheetAlert = Alert(title: "Action Sheet", message: "What's up", priority: .medium, style: .actionSheet, alertActions: nil)
        actionSheetAlert.actions.append(.defaultAction())
        AlertCoordinator.main.enqueue(alert: actionSheetAlert)
        
        for i in 0...5 {
            let alert = Alert(title: "\(i)", message: "", alertActions: nil)
            alert.actions = [.defaultAction(), dispatchAction]
            
            AlertCoordinator.main.enqueue(alert: alert)
        }
        
        let textAlert = Alert(title: "Hey", message: "Yo", alertActions: nil)
        textAlert.actions = [.defaultAction()]
        textAlert.alertController.addTextField(configurationHandler: nil)
        
        AlertCoordinator.main.enqueue(alert: textAlert)
        AlertCoordinator.main.display()
    }
}

