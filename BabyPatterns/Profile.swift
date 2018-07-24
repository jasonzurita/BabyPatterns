import UIKit

// TOOD: check if userID is used
public struct Profile {
    public var babyName: String
    public var parentName: String
    public var babyDOB: Date
    public var email: String
    public let userID: String
    public var serverKey: String?
    public var desiredMaxSupply: SupplyAmount
    public var profilePicture: UIImage?

    public init(babyName: String,
                parentName: String,
                babyDOB: Date,
                email: String,
                userID: String,
                serverKey: String? = nil,
                desiredMaxSupply: SupplyAmount,
                profilePicture: UIImage? = nil) {
        self.babyName = babyName
        self.parentName = parentName
        self.profilePicture = profilePicture
        self.babyDOB = babyDOB
        self.email = email
        self.userID = userID
        self.serverKey = serverKey
        self.desiredMaxSupply = desiredMaxSupply
    }

    public func json() -> [String: Any] {
        return [
            K.JsonFields.BabyName: babyName,
            K.JsonFields.ParentName: parentName,
            K.JsonFields.BabyDOB: babyDOB.timeIntervalSince1970,
            K.JsonFields.Email: email,
            K.JsonFields.UserID: userID,
            K.JsonFields.DesiredMaxSupply: desiredMaxSupply,
        ]
    }
}
