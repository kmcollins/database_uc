//
//  DetailMedViewController.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 2/2/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DetailMedViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    
    var medName: String! {
        didSet {
            navigationItem.title = medName
        }
    }
        
    var med: Medication!
    
    var medDose: Double?
    
    var medFreq: Int32?
    
    var appearance: String?
    
    var key: String?
    
    let imagePicker = UIImagePickerController()
    
    var data: NSData?
    
    var ref: FIRDatabaseReference?
    var uid: String?
    
    //var medIndex: Int!
    
    @IBOutlet var doseTF: UITextField!
    @IBOutlet var freqTF: UITextField!
    @IBOutlet var appTF: UITextField!
    
    override func viewDidLoad() {
        self.doseTF.delegate = self
        self.appTF.delegate = self
        self.freqTF.delegate = self
        
        self.appearance = self.med.appearance
        self.medDose = self.med.dosage
        self.medFreq = self.med.dailyFreq
        
        self.key = self.med.imageKey
        print("key in class: \(self.key)")
        
        self.appTF.text = self.appearance!
        self.doseTF.text = String(self.medDose!)
        self.freqTF.text = String(self.medFreq!)
        
        self.data = self.med.imageData
        
        if let imageData = data {
            if let imageToDisplay = UIImage(data: imageData as Data) {
                imageView.image = imageToDisplay
            }
        }
        
        print("image in view: \(imageView.image)")
        
        imagePicker.delegate = self
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate

        ref = FIRDatabase.database().reference()
        
        guard let currentUserID = appDelegate.uid else {
            self.uid = nil
            return
        }
        
        self.uid = currentUserID
    }
    
    @IBAction func saveMed(_ sender: Any) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        print("original \(med)")
        
        context.delete(med)
        appDelegate.saveContext()
        
        let newMed = Medication(context: context)
        newMed.appearance = appTF.text!
        if let newFreq = Int32(freqTF.text!) {
            newMed.dailyFreq = newFreq
        } else {
            newMed.dailyFreq = 0
        }
        if let newDose = Double(doseTF.text!) {
            newMed.dosage = newDose
        } else {
            newMed.dosage = 0.0
        }
        newMed.name = medName
        //newMed.imageKey = med.imageKey
        newMed.imageKey = key
        newMed.imageData = data
        appDelegate.saveContext()
        med = newMed
        print("saving \(med)")
        
        // FIREBASE!!!!
        guard let database = ref, let user = uid else {
            return
        }
        
        database.child("users").child(user).child("medications").child("\(medName)").setValue(["name": medName, "imageKey": key ?? "", "imageData": data, "dosage": (Double(doseTF.text!) ?? 0.0) , "dailyFreq": (Int32(doseTF.text!) ?? 0), "appearance": appTF.text!])
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == doseTF {
            doseTF.resignFirstResponder()
        }
        else if textField == freqTF {
            freqTF.resignFirstResponder()
        }
        else if textField == appTF {
            appTF.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera;
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = false
        } else {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
        }
        
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let image = self.resizeImage(image: chosenImage, targetSize: CGSize.init(width: 100, height: 100))
        
        let data = UIImagePNGRepresentation(image) as NSData?
        self.data = data
        
        imageView.image = image
        
        //dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
