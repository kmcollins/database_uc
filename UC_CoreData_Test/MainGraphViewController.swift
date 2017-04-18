//
//  MainGraphViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 2/15/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class MainGraphViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    //var entries: [Entry] = []
    var entries: NSDictionary?
    var dates: [String] = []
    
    let pickerData = ["PUCAI Score", "Number of Stools", "Stool Consistency", "Nocturnal", "Rectal Bleeding", "Activity Level", "Abdominal Pain"]
    
    @IBOutlet var graphPicker: UIPickerView!
    
    @IBOutlet var graph: GraphView!
    
    var maxHeight = 85
    
    var ref: FIRDatabaseReference?
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        /*let context = appDelegate.persistentContainer.viewContext
        
        do {
            self.entries = try context.fetch(Entry.fetchRequest()) as! [Entry]
            
            guard entries.count > 0 else {
                print("ERROR")
                return
            }
            
            self.dates = setUpDates()
            
            graphPicker.dataSource = self
            graphPicker.delegate = self
            
            setUpGraphWithData(data: pucaiArray())
        }
        catch {
            print("ERROR")
        }*/
        
        ref = FIRDatabase.database().reference()
        
        guard let currentUserID = appDelegate.uid else {
            self.uid = nil
            return
        }
        
        self.uid = currentUserID
        
        retrieveFirebaseData()
        
        graphPicker.dataSource = self
        graphPicker.delegate = self
        
        //setUpGraphWithData(data: pucaiArray())
    }
    
    func retrieveFirebaseData() {
        
        guard let userID = uid else {
            print("ERROR: no current user")
            return
        }
        
        ref?.child("users").child(userID).child("entries").observeSingleEvent(of: .value, with: { (snapshot) in
            
            /*
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let user = User.init(username: username)*/
            
            //po ((snapshot.value as? NSDictionary)?["2017-04-17 03:35:15"] as!NSDictionary)["pucaiScore"]!
            
            /*let dict = snapshot.value as? NSDictionary
            print("dict: \(dict)")
            print("entries: \(dict?["entries"] as? NSDictionary)")
            self.entries = dict?["entries"] as? NSDictionary*/
            
            self.entries = snapshot.value as? NSDictionary
            
            if self.entries != nil && self.entries!.count > 0 {
                self.dates = self.entries!.allKeys as! [String]
                self.setUpGraphWithData(data: self.pucaiArray())
            } else {
               print("ERROR: no entries /n Cannot make graph until data is entered")
            }
            
            //self.entries = snapshot as NSDictionary
            /*guard self.entries!.count > 0 else {
                
                return
            }*/
            //self.dates = self.setUpDates()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setUpDates() -> [String]{
        var dates: [String] = []
        /*
        let myFormatter = DateFormatter()
        myFormatter.dateStyle = .short
        for e in entries {
            let date = e.date
            dates.append(myFormatter.string(from: date as! Date))
        }*/
        for (_,v) in entries! {
            let date = v
            //dates.append(myFormatter.string(from: date as! Date))
            dates.append(date as! String)
        }
        setUpGraphWithData(data: pucaiArray())
        return dates
    }
 
    func pucaiArray() -> [Int]{
        var pucai: [Int] = []
        /*for e in entries {
            pucai.append(Int(e.pucaiScore))
        }*/
        
        //((snapshot.value as? NSDictionary)?["2017-04-17 03:35:15"] as!NSDictionary)["pucaiScore"]!
        
        /*let dates = entries!.allValues as? NSDictionary
        for (k,v) in dates! {
            if (k as! String) == "pucaiScore" {
                pucai.append(Int(v as! Int16))
            }
        }*/
        
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            pucai.append(Int(entry["pucaiScore"] as! Int16))
        }
        
        
        maxHeight = 85
        return pucai
    }
    
    func nocturnalArray() -> [Int]{
        var nocturnal: [Int] = []
        /*for e in entries {
            nocturnal.append(Int(e.nocturnal))
        }*/
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            nocturnal.append(Int(entry["nocturnal"] as! Int16))
        }
        maxHeight = 10
        return nocturnal
    }
    
    func bleedingArray() -> [Int]{
        var rectalBleeding: [Int] = []
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            rectalBleeding.append(Int(entry["rectalBleeding"] as! Int16))
        }
        maxHeight = 30
        return rectalBleeding
    }
    
    func activityLevelArray() -> [Int]{
        var activityLevel: [Int] = []
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            activityLevel.append(Int(entry["activityLevel"] as! Int16))
        }
        maxHeight = 10
        return activityLevel
    }
    
    func abdPainArray() -> [Int]{
        var abdominalPain: [Int] = []
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            abdominalPain.append(Int(entry["abdominalPain"] as! Int16))
        }
        maxHeight = 10
        return abdominalPain
    }
    
    func numStoolsArray() -> [Int]{
        var numStools: [Int] = []
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            numStools.append(Int(entry["numStools"] as! Int16))
        }
        maxHeight = 15
        return numStools
    }
    
    func consistencyArray() -> [Int]{
        var stoolConsistency: [Int] = []
        for d in dates {
            let entry = entries?[d] as! NSDictionary
            stoolConsistency.append(Int(entry["stoolConsistency"] as! Int16))
        }
        maxHeight = 10
        return stoolConsistency
    }
    
    func setUpGraphWithData(data: [Int]) {
        graph.vals = data
        graph.number = entries!.allKeys.count
        graph.maxHeight = maxHeight
        graph.dates = dates
        graph.setNeedsDisplay()
    }
    
    // Returns the number of 'columns' to display...UIPickerView!
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // Returns the # of rows in each component.. ..UIPickerView!
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        let identifier = pickerData[row]
        
        switch (identifier) {
        case "PUCAI Score":
            setUpGraphWithData(data: pucaiArray())
        case "Stool Consistency":
            setUpGraphWithData(data: consistencyArray())
        case "Activity Level":
            setUpGraphWithData(data: pucaiArray())
        case "Number of Stools":
            setUpGraphWithData(data: numStoolsArray())
        case "Abdominal Pain":
            setUpGraphWithData(data: abdPainArray())
        case "Rectal Bleeding":
            setUpGraphWithData(data: bleedingArray())
        case "Nocturnal":
            setUpGraphWithData(data: nocturnalArray())
        default:
            break
        }
    }
    
}
 
