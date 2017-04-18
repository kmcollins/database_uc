//
//  ViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 1/28/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    
   /* http://stackoverflow.com/questions/32611760/swift-core-data-sync-with-web-server */

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var sexSegControl: UISegmentedControl!
    
    @IBAction func pressedDone(_ sender: Any) {
        createPatient()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        ageTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            nameTextField.resignFirstResponder()
        }
        else if textField == ageTextField {
            ageTextField.resignFirstResponder()
        }
        return true
    }
    
    func createPatient() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let patient = Patient(context: context)
        
        patient.name = nameTextField.text!
        patient.age = Int32(ageTextField.text!)!
        if sexSegControl.selectedSegmentIndex  == 0 {
            patient.sex = true // female
        } else {
            patient.sex = false // male
        }
        
        appDelegate.saveContext()
        // for now ... 
        retrievePatients()
    }
    
    func retrievePatients() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let patients = try context.fetch(Patient.fetchRequest()) as! [Patient]
            for p in patients {
                print("Name: \(p.name!)")
                print("\tAge: \(p.age)")
                let sex = p.sex ? "female" : "male"
                print("\tSex: \(sex)")
            }
        }
        catch {
            print("ERROR")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

