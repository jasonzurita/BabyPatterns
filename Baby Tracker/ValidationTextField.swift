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
    case custom(() -> ValidationResult)
}

enum ValidationResult {
    case success
    case failure(String)
}

class ValidationTextField: UITextField {

    var type:TextFieldType = .text
    
    func isValid() -> ValidationResult {
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
    
    private func textValidation() -> ValidationResult {
        return (text?.isEmpty ?? false ) ? .success : .failure("Empty text")
    }
    
    //TODO: implement us!
    private func emailValidation() -> ValidationResult {
        return textValidation()
    }
    
    private func phoneNumberValidation() -> ValidationResult {
        return textValidation()
    }
    
    private func dobValidation() -> ValidationResult {
        return textValidation()
    }
    
}
