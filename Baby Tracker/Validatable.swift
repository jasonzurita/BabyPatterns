//
//  Validatable.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/11/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

enum ValidationType {
    case text(length: Int)
    case email
    case phoneNumber
    case dateOfBirth
    case password
    case custom((String) -> ValidationResult)
}

enum ValidationResult {
    case success
    case failure(reason: String)
}

protocol Validatable {
    func validate(_ value: String?, type: ValidationType) -> ValidationResult
}

extension Validatable {
    func validate(_ value: String?, type: ValidationType) -> ValidationResult {
        guard let v = value else { return .failure(reason: "no text to validate") }

        switch type {
        case let .text(length):
            return validate(text: v, length: length)
        case .email:
            return validate(email: v)
        case .phoneNumber:
            return validate(phoneNumber: v)
        case .dateOfBirth:
            return validate(dateOfBirth: v)
        case .password:
            return validate(password: v)
        case let .custom(validator):
            return validator(v)
        }
    }

    private func validate(text: String, length: Int) -> ValidationResult {
        return text.count >= length ? .success : .failure(reason: "text too short")
    }

    private func validate(email: String) -> ValidationResult {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return .failure(reason: "validation failed")
        }
        let range = NSRange(location: 0, length: email.count)
        let addresses = detector
            .matches(in: email, options: [], range: range)
            .flatMap {
                guard let matchURL = $0.url else { return nil }
                guard let components = URLComponents(url: matchURL, resolvingAgainstBaseURL: false) else { return nil }
                guard components.scheme == "mailto" else { return nil }

                return components.path
            }

        return addresses.isEmpty ? .failure(reason: "invalid email") : .success
    }

    private func validate(phoneNumber _: String) -> ValidationResult {
        // TODO: implement validation
        return .success
    }

    private func validate(dateOfBirth _: String) -> ValidationResult {
        // TODO: implement validation
        return .success
    }

    private func validate(password _: String) -> ValidationResult {
        // TODO: implement validation
        return .success
    }
}
