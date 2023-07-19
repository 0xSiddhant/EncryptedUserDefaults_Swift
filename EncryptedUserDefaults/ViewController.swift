//
//  ViewController.swift
//  EncryptedUserDefaults
//
//  Created by Siddhant Kumar on 19/07/23.
//

import UIKit

class ViewController: UIViewController {

    let encryptedDefaults = EncryptedUserDefaults(level: .normal)
    
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*
         1. Print all key values
         2. delete all key value
         3. set encryption level of AES ecnryption
         4. change value type base on text i.e 1 -> Int | 1.2 -> Double | true -> Bool | 15 word long text -> Data
         
         */
    }

    @IBAction func printAllAction(_ sender: Any) {
        print(UserDefaults.standard.dictionaryRepresentation())
        print("------------------------------------")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.contains("_encrypted") {
                print("\(key) => \(encryptedDefaults.getValue(forKey: key))\n")
            } else {
                print("\(key) => \(UserDefaults.standard.object(forKey: key)!)\n")
            }
        }
    }
    
    @IBAction func saveValueAction(_ sender: UIButton) {
        if keyField.text!.isEmpty {
            print("Key empty")
            return
        }
        addValueAfterEncryption(valueField.text!, for: keyField.text!)
        
        keyField.text = ""
        valueField.text = ""
    }
    
    @IBAction func emptyAllKeysAction(_ sender: Any) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
    }
    
}

extension ViewController {
    
    func addValueAfterEncryption(_ value: String, for key: String) {
        UserDefaults.standard.setValue(value, forKey: "\(key)_normal")
        
        encryptedDefaults.setValue(value, forKey: "\(key)_encrypted")

        if let decryptedValue = encryptedDefaults.getValue(forKey: "\(key)_encrypted") {
            print("Decrypted value: \(decryptedValue)")
        }
    }
}
