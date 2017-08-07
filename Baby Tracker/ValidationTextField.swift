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
    case password
    case custom(() -> Bool)
}

class ValidationTextField: UITextField, Shakeable {

    var type: TextFieldType = .text

    func isValid() -> Bool {
        var isValid = false

        switch type {
        case .text:
            isValid = isTextValid()
        case .email:
            isValid = isEmailValid()
        case .phoneNumber:
            isValid = isPhoneNumberValid()
        case .dateOfBirth:
            isValid = isDOBValid()
        case .password:
            isValid = isPasswordValid()
        case .custom(let validation):
            isValid = validation()
        }

        if !isValid { shake() }

        return isValid
    }

    private func isTextValid() -> Bool {
        return !(text?.isEmpty ?? true)
    }

    //TODO: implement us!
    private func isEmailValid() -> Bool {
        return isTextValid()
    }

    private func isPhoneNumberValid() -> Bool {
        return isTextValid()
    }

    private func isDOBValid() -> Bool {
        return isTextValid()
    }

    private func isPasswordValid() -> Bool {
        return isTextValid()
    }
}
