//
//  MainDataViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 1/30/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MainDataViewController: UIViewController {
    
    @IBOutlet var activityLevel: UISegmentedControl!
    @IBOutlet var nocturnal: UISegmentedControl!
    @IBOutlet var numStools: UISegmentedControl!
    @IBOutlet var rectBleeding: UISegmentedControl!
    @IBOutlet var stoolConstistency: UISegmentedControl!
    @IBOutlet var abdPain: UISegmentedControl!
    
    //var triggers: Triggers!
    
    let triggerNames: [String] = ["Milk", "Math Test", "Gluten", "Track Race", "Pizza", "Coffee"]
    
    var goToGraph = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reset()
        if goToGraph { self.presentGraph() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "continueEntry" {
            let todaysTriggersCntrl = segue.destination as! TodaysTriggersController
            todaysTriggersCntrl.abdPain = abdPain.selectedSegmentIndex
            todaysTriggersCntrl.stoolConsistency = stoolConstistency.selectedSegmentIndex
            todaysTriggersCntrl.numStools = numStools.selectedSegmentIndex
            todaysTriggersCntrl.nocturnal = nocturnal.selectedSegmentIndex
            todaysTriggersCntrl.activityLevel = activityLevel.selectedSegmentIndex
            todaysTriggersCntrl.rectBleeding = rectBleeding.selectedSegmentIndex
            //todaysTriggersCntrl.triggers = triggers
        }
    }
    
    func reset() {
        let segControls: [UISegmentedControl] = [activityLevel, nocturnal, numStools, rectBleeding, stoolConstistency, abdPain]
        segControls.map{$0.selectedSegmentIndex = 0} // data back to normal
    }
    
    func presentGraph() {
        // NOTE: this will change if we change the tab order!!!!!!
        // Not good code
        self.goToGraph = false
        tabBarController?.selectedIndex = 4
    }
    
}
