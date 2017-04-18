//
//  MedsTableViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 2/2/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MedsTableViewController: UITableViewController {
    //var triggers: Triggers!
    let nm = NotificationsManager()
    
    var meds: [Medication] = []
    
    @IBAction func addNewMedication(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "New Medication", message: "Add a medication.", preferredStyle: .alert)
        
        let addNewAction = UIAlertAction(title: "Add", style: .default){(_) in
            let nameTextField = alert.textFields![0]
            /*let doseTextField = alert.textFields![1]
            let frequencyTextField = alert.textFields![2]
            let appearanceTextField = alert.textFields![3]
            self.createMedication(withName: nameTextField.text!, withDose: doseTextField.text!, withFreq: frequencyTextField.text!, withAppearance: appearanceTextField.text!)*/
            self.createMedication(withName: nameTextField.text!, withDose: "0", withFreq: "0", withAppearance: "")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(addNewAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func createMedication(withName name: String, withDose dose: String, withFreq freq: String, withAppearance apprc: String) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let med = Medication(context: context)
        
        med.name = name
        med.appearance = apprc
        med.dailyFreq = Int32(freq)!
        med.dosage = Double(dose)!
        
        med.imageKey = UUID().uuidString
        
        appDelegate.saveContext()
        
        updateMedsArray()
        
        let indexPath = IndexPath(row: meds.count - 1, section: 0)
        // Insert this new row into the table
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        nm.newNotification(med: name, mph: med.dailyFreq != 0 ? med.dailyFreq : 24)
        
        
    }
    
    func updateMedsArray() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            meds = try context.fetch(Medication.fetchRequest()) as! [Medication]
        }
        catch {
            print("ERROR")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultMedCell", for: indexPath) as! UITableViewCell
        
        /* Set the text on the cell w/ the description of the item
         that is at the nth index of items, where n = row this cell
         will appear in on the tableView */
        let medName = meds[indexPath.row].name
        
        cell.textLabel?.text = medName
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // If tableView is asking to commit a delete command ...
        if editingStyle == .delete {
            //let trigger = triggers.triggerNames[indexPath.row]
            let medication = meds[indexPath.row]
            
            let title = "Delete \(medication.name!)?"
            let message = "Are you sure you want to delete this medication?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                             handler: { (action) -> Void in
                                                let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
                                                let context = appDelegate.persistentContainer.viewContext
                                                
                                                context.delete(medication)
                                                appDelegate.saveContext()
                                                
                                                self.updateMedsArray()
                                                
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
        if segue.identifier == "showMed" {
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get item associate w/ that row
                // let name = triggers.triggerNames[row]
                let med = meds[row]
                let detailViewController = segue.destination as! DetailMedViewController
                detailViewController.med = med
                detailViewController.medName = med.name
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
            self.meds = try context.fetch(Medication.fetchRequest()) as! [Medication]
            /*
             NOTE: to delete the core data and medications and reset JUST the medications, uncomment the line below as well as the function deleteAll()
             When you have run the app w/ this (you must click on the medications tab for the code to execute ... recomment the below line so that the function deleteAll() does not run 
             Then, you can go about adding medications again
             You need to do this b/c I changed the core data entity for medications --- NOTE, the changes to core data should not affect reminders, only images 
            self.deleteAll()
            */
        }
        catch {
            print("ERROR")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMedsArray()
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    /*
     NOTE: This function is for testing purposes only --- this will clear the core data for medications ... watch out! 
    private func deleteAll() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            for m in self.meds {
                context.delete(m)
            }
            appDelegate.saveContext()
        }
        catch {
            print("ERROR")
        }
    }*/
}
