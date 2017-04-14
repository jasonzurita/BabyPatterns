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
    
    func isValid() -> Bool {
        var isValid = false
        
        switch type {
        case .text:
            isValid = isTextValid()
        case .email:
            isValid = emailValidation()
        case .phoneNumber:
            isValid = phoneNumberValidation()
        case .dateOfBirth:
            isValid = isTextValid()
        case .custom(let validation):
            isValid = validation()
        }
        
        if !isValid {
            shake()
        }
        
        return isValid
    }
    
    private func isTextValid() -> Bool {
        return !(text?.isEmpty ?? true)
    }
    
    //TODO: implement us!
    private func emailValidation() -> Bool {
        return isTextValid()
    }
    
    private func phoneNumberValidation() -> Bool {
        return isTextValid()
    }
    
    private func dobValidation() -> Bool {
        return isTextValid()
    }
}
