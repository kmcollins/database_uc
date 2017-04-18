//
//  DetailTriggerViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 1/31/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class DetailTriggerViewContoller: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var entries: [Entry] = []
    var dates: [String] = []
    
    let pickerData = ["PUCAI Score", "Number of Stools", "Stool Consistency", "Nocturnal", "Rectal Bleeding", "Activity Level", "Abdominal Pain"]
    
    var triggerName: String! {
        didSet {
            navigationItem.title = triggerName
        }
    }
    
    var maxHeight = 85
    
    @IBOutlet var graph: GraphView!
    @IBOutlet var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let unfilteredEntries = try context.fetch(Entry.fetchRequest()) as! [Entry]
            self.entries = filterEntries(unfilteredEntries)
            
            guard entries.count > 0 else {
                print("ERROR")
                return
                // later change this to show on the graph that no data has been entered yet
            }
            
            self.dates = setUpDates()
            
            picker.dataSource = self
            picker.delegate = self
            
            setUpGraphWithData(data: pucaiArray())
            
        }
        catch {
            print("ERROR")
        }
    }
    
    func filterEntries(_ data: [Entry]) -> [Entry] {
        var filteredEntries: [Entry] = []
        for entry in data {
            if let triggers = entry.triggerArrayAsString?.components(separatedBy: ";") {
                if triggers.contains(triggerName) { filteredEntries.append(entry) }
            }
        }
        return filteredEntries // these are the entries wherein the trigger occured
    }
    
    func setUpDates() -> [String]{
        var dates: [String] = []
        let myFormatter = DateFormatter()
        myFormatter.dateStyle = .short
        for e in entries {
            let date = e.date
            dates.append(myFormatter.string(from: date as! Date))
        }
        return dates
    }
    
    func pucaiArray() -> [Int]{
        var pucai: [Int] = []
        for e in entries {
            pucai.append(Int(e.pucaiScore))
        }
        maxHeight = 85
        return pucai
    }
    
    func nocturnalArray() -> [Int]{
        var nocturnal: [Int] = []
        for e in entries {
            nocturnal.append(Int(e.nocturnal))
        }
        maxHeight = 10
        return nocturnal
    }
    
    func bleedingArray() -> [Int]{
        var rectalBleeding: [Int] = []
        for e in entries {
            rectalBleeding.append(Int(e.rectalBleeding))
        }
        maxHeight = 30
        return rectalBleeding
    }
    
    func activityLevelArray() -> [Int]{
        var activityLevel: [Int] = []
        for e in entries {
            activityLevel.append(Int(e.activityLevel))
        }
        maxHeight = 10
        return activityLevel
    }
    
    func abdPainArray() -> [Int]{
        var abdominalPain: [Int] = []
        for e in entries {
            abdominalPain.append(Int(e.abdominalPain))
        }
        maxHeight = 10
        return abdominalPain
    }
    
    func numStoolsArray() -> [Int]{
        var numStools: [Int] = []
        for e in entries {
            numStools.append(Int(e.numStools))
        }
        maxHeight = 15
        return numStools
    }
    
    func consistencyArray() -> [Int]{
        var stoolConsistency: [Int] = []
        for e in entries {
            stoolConsistency.append(Int(e.stoolConsistency))
        }
        maxHeight = 10
        return stoolConsistency
    }
    
    func setUpGraphWithData(data: [Int]) {
        graph.vals = data
        graph.number = entries.count
        graph.maxHeight = maxHeight
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
            setUpGraphWithData(data: activityLevelArray())
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
