import Foundation

// TODO: consider making a new type that is a facade for String
// like validatableString, and extend that. This wouldn't globablly
// make string validatable, which is a domain specific extension.
public extension String {
    func validateEmail() -> Bool {
        return true
    }
}
