//
//  TodaysTriggersController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 1/31/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class TodaysTriggersController: UITableViewController {
    //var triggers: Triggers!
    
    var triggers: [Trigger] = [] 
    
    var activityLevel: Int!
    var numStools: Int!
    var rectBleeding: Int!
    var abdPain: Int!
    var stoolConsistency: Int!
    var nocturnal: Int!

    var pucaiScore = 0
    
    var ref: FIRDatabaseReference?
    var uid: String?
    
    @IBAction func doneWithEntry(_ sender: UIButton) {
        // This is where the final entry will be saved
        createEntry()
    }
    
    @IBAction func addNewTrigger(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New Trigger", message: "Add a trigger.", preferredStyle: .alert)
        
        let addNewAction = UIAlertAction(title: "Add", style: .default){(_) in
            let nameTextField = alert.textFields![0]
            self.createTrigger(withName: nameTextField.text!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(addNewAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func createTrigger(withName name: String) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let trig = Trigger(context: context)
        
        trig.name = name
        
        appDelegate.saveContext()
        
        do {
            triggers = try context.fetch(Trigger.fetchRequest()) as! [Trigger]
        }
        catch {
            print("ERROR")
        }
        
        let indexPath = IndexPath(row: triggers.count - 1, section: 0)
        // Insert this new row into the table
        tableView.insertRows(at: [indexPath], with: .automatic)
        
    }
    
    func convertToScore() {
        // convert all indexes to PUCAI scores
        var actLev: Int = 0
        var noct: Int = 0
        var abPain: Int = 0
        var rect: Int = 0
        var const: Int = 0
        var num: Int = 0
        switch activityLevel {
        case 0:
            actLev = 0
        case 1:
            actLev = 5
        case 2:
            actLev = 10
        default:
            break
        }
        switch nocturnal {
        case 0:
            noct = 0
        case 1:
            noct = 10
        default:
            break
        }
        switch abdPain {
        case 0:
            abPain = 0
        case 1:
            abPain = 5
        case 2:
            abPain = 10
        default:
            break
        }
        switch numStools {
        case 0:
            num = 0
        case 1:
            num = 5
        case 2:
            num = 10
        case 3:
            num = 15
        default:
            break
        }
        switch rectBleeding {
        case 0:
            rect = 0
        case 1:
            rect = 10
        case 2:
            rect = 20
        case 3:
            rect = 30
        default:
            break
        }
        switch stoolConsistency {
        case 0:
            const = 0
        case 1:
            const = 5
        case 2:
            const = 10
        default:
            break
        }
        
        pucaiScore += const + rect + num + noct + abPain + actLev
        
    }
    
    func createEntry() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entry = Entry(context: context)
        
        entry.date = NSDate() // current date + time
        entry.activityLevel = Int16(activityLevel)
        entry.numStools = Int16(numStools)
        entry.stoolConsistency = Int16(stoolConsistency)
        entry.nocturnal = Int16(nocturnal)
        entry.abdominalPain = Int16(abdPain)
        entry.rectalBleeding = Int16(rectBleeding)
        convertToScore()
        entry.pucaiScore = Int16(pucaiScore)
        
        
        // FIREBASE version ....
        
        guard let database = ref, let user = uid else {
            return
        }
        
        convertToScore()
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "triggerCell", for: indexPath) as! TriggerCell
        let cells = self.tableView.visibleCells as! [TriggerCell]
        var todaysTriggers: [String] = []
        for c in cells {
            if c.occuredSwitch.isOn {
                todaysTriggers.append(c.nameLabel.text!)
            }
        }
        
        // list of triggers for that day is stored as an array
        // turn array into strings
        //let arrayAsString = triggers.triggerNames.joined(separator: ";")
        if todaysTriggers.count != 0 {
            
            let date = NSDate()
            let myFormatter = DateFormatter()
            myFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            let arrayAsString = todaysTriggers.joined(separator: ";")
            entry.triggerArrayAsString = arrayAsString
            database.child("users").child(user).child("entries").child(myFormatter.string(from: date as Date)).setValue(["pucaiScore": Int16(pucaiScore), "numStools": Int16(numStools), "activityLevel": Int16(activityLevel), "stoolConsistency": Int16(stoolConsistency), "nocturnal": Int16(nocturnal), "rectalBleeding": Int16(rectBleeding), "abdominalPain": Int16(abdPain), "triggerArrayAsString": arrayAsString])
            
        } else {
            
            let date = NSDate()
            let myFormatter = DateFormatter()
            myFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            entry.triggerArrayAsString = nil
            database.child("users").child(user).child("entries").child(myFormatter.string(from: date as! Date)).setValue(["pucaiScore": Int16(pucaiScore), "numStools": Int16(numStools), "activityLevel": Int16(activityLevel), "stoolConsistency": Int16(stoolConsistency), "nocturnal": Int16(nocturnal), "rectalBleeding": Int16(rectBleeding),"abdominalPain": Int16(abdPain), "triggerArrayAsString": ""])
        }
        
        appDelegate.saveContext()
        // for now ...
        retrieveEntries()
        
    }
    
    func retrieveEntries() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let entries = try context.fetch(Entry.fetchRequest()) as! [Entry]
            for e in entries {
                print("Date: \(e.date!)")
                print("\tPUCAI Score: \(e.pucaiScore)")
                if let triggers = e.triggerArrayAsString?.components(separatedBy: ";") {
                    print("\tTriggers: ")
                    for t in triggers {
                        print("\t\t\(t)")
                    }
                }
            }
        }
        catch {
            print("ERROR")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return triggers.triggerNames.count
        return triggers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "triggerCell", for: indexPath) as! TriggerCell
        
        // Update the labels for the new preferred text size
        cell.updateLabels()
        
        /* Set the text on the cell w/ the description of the item
         that is at the nth index of items, where n = row this cell
         will appear in on the tableView */
        //let trigName = triggers.triggerNames[indexPath.row]
        let trigName = triggers[indexPath.row].name
        
        cell.nameLabel.text = trigName
        
        return cell
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSegue" {
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get item associate w/ that row
                let name = triggers.triggerNames[row]
                let detailViewController = segue.destination as! DetailTriggerViewContoller
                detailViewController.triggerName = name
            }
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            self.triggers = try context.fetch(Trigger.fetchRequest()) as! [Trigger]
        }
        catch {
            print("ERROR")
        }
        
        ref = FIRDatabase.database().reference()
        
        guard let currentUserID = appDelegate.uid else {
            self.uid = nil
            return
        }
        
        self.uid = currentUserID
    }
    
    @IBAction func done(_ sender: Any) {
        let root = navigationController?.viewControllers[0] as! MainDataViewController
        root.goToGraph = true // NOTE: this is bad code ... how can this be improved?
        self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

}

