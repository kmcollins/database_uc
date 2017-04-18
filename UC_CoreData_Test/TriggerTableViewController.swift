//
//  TriggerTableViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 1/30/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TriggerTableViewController: UITableViewController {
    //var triggers: Triggers!
    
    var triggers: [Trigger] = []
    
    @IBAction func addNewTrigger(_ sender: AnyObject) {
        // Create a new item and add it to the store
        
        /*
        let newTrigger = ""
        triggers.createTrigger(withName: newTrigger)
        
        // Figure out where that item is in the array
        if let index = triggers.triggerNames.index(of: newTrigger) {
            let indexPath = IndexPath(row: index, section: 0)
            // Insert this new row into the table
            tableView.insertRows(at: [indexPath], with: .automatic)
        }*/
        
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
        
        updateTriggerArray()
        
        let indexPath = IndexPath(row: triggers.count - 1, section: 0)
        // Insert this new row into the table
        tableView.insertRows(at: [indexPath], with: .automatic)
        
    }
    
    func updateTriggerArray() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            triggers = try context.fetch(Trigger.fetchRequest()) as! [Trigger]
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
        /*
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "triggerCell", for: indexPath) as! TriggerCell
        
        // Update the labels for the new preferred text size
        cell.updateLabels()
        
        /* Set the text on the cell w/ the description of the item
         that is at the nth index of items, where n = row this cell
         will appear in on the tableView */
        let trigName = triggers.triggerNames[indexPath.row]
        
        cell.nameLabel.text = trigName
        
        return cell*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath) as! UITableViewCell
        
        /* Set the text on the cell w/ the description of the item
         that is at the nth index of items, where n = row this cell
         will appear in on the tableView */
        //let trigName = triggers.triggerNames[indexPath.row]
        let trigName = triggers[indexPath.row].name
        
        cell.textLabel?.text = trigName
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // If tableView is asking to commit a delete command ...
        if editingStyle == .delete {
            //let trigger = triggers.triggerNames[indexPath.row]
            let trigger = triggers[indexPath.row]
            
            let title = "Delete \(trigger.name!)?"
            let message = "Are you sure you want to delete this trigger?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                             handler: { (action) -> Void in
                                                // Remove item from the store
                                                //self.triggers.removeTrigger(withName: trigger)
                                                let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
                                                let context = appDelegate.persistentContainer.viewContext
                                                
                                                context.delete(trigger)
                                                appDelegate.saveContext()
                                                
                                                self.updateTriggerArray()
                                                
                                                // Also remove that row from the table view w/ animation
                                                self.tableView.deleteRows(at: [indexPath], with: .automatic)

                                                
            })
            
            ac.addAction(deleteAction)
            
            // Present the alert controller
            present(ac, animated: true, completion: nil)
        }
    }
    /*
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        itemStore.moveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSegue" {
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get item associate w/ that row
                // let name = triggers.triggerNames[row]
                let name = triggers[row].name
                let detailViewController = segue.destination as! DetailTriggerViewContoller
                detailViewController.triggerName = name
            }
        }
    }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
}
