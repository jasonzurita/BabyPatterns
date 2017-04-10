//
//  ValidationTextField.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/28/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

enum TextFieldType {
    case text
    case email
    case phoneNumber
    case dateOfBirth
    case custom(() -> Bool)
}

class ValidationTextField: UITextField, Shakeable {

    var type:TextFieldType = .text
    
    func validate() -> Bool {
        switch type {
        case .text:
            return textValidation()
        case .email:
            return emailValidation()
        case .phoneNumber:
            return phoneNumberValidation()
        case .dateOfBirth:
            return textValidation()
        case .custom(let validation):
            return validation()
        }
    }
    
    private func textValidation() -> Bool {
        guard let t = text, !t.isEmpty  else {
            shake()
            return false
        }
        
        return true
    }
    
    //TODO: implement us!
    private func emailValidation() -> Bool {
        return textValidation()
    }
    
    private func phoneNumberValidation() -> Bool {
        return textValidation()
    }
    
    private func dobValidation() -> Bool {
        return textValidation()
    }
}

//
//enum SignUpValidationError: String, Error {
//    case invalidEmail = "Invalid email entered."
//    case invalidPassword = "Invalid password entered."
//    case noNameEntered = "No name entered."
//    case noBabyNameEntered = "No baby name entered."
//    case noBabyDOBEntered = "No date of birth entered."
//}

