import Foundation

public enum ValidationType {
    case text(length: Int)
    case email
    case phoneNumber
    case dateOfBirth
    case password(length: Int)
    case custom((String) -> ValidationResult)
}

public enum ValidationResult {
    case success
    case failure(reason: String)
}

public protocol Validatable {
    func validate(_ value: String?, type: ValidationType) -> ValidationResult
}

public extension Validatable {
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
        case let .password(length):
            return validate(password: v, requiredPasswordLength: length)
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
            .compactMap { (result: NSTextCheckingResult) -> String? in
                guard let matchURL = result.url else { return nil }
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

    private func validate(password: String, requiredPasswordLength: Int) -> ValidationResult {
        return password.count >= requiredPasswordLength ?
            .success :
            .failure(reason: "you password must be greater than \(requiredPasswordLength) characters")
    }
}
