public struct K {
    public struct NibNames {
        // TODO: update this to use the acutal class name to make it more robust
        public static let SignIn = "SignInVC"
    }

    public struct Segues {
        // app launch
        public static let LoggedIn = "LoggedInSegue"
        public static let LoggedOut = "LoggedOutSegue"

        // logged out
        public static let SignedIn = "SignedInSegue"

        // home vc
        public static let Feeding = "FeedingSegue"

        // edit profile image
        public static let EditProfileImage = "EditProfileImageSegue"
    }

    public struct JsonFields {
        // feeding
        public static let FeedingType = "type"
        public static let Side = "side"
        public static let StartDate = "startDate"
        public static let EndDate = "endDate"
        public static let LastPausedDate = "lastPausedDate"
        public static let SupplyAmount = "supplyAmount"
        public static let PausedTime = "pausedTime"
        public static let FeedingQuantity = "quantity"
        public static let Duration = "duration"

        // profile
        public static let ParentName = "parentName"
        public static let BabyName = "babyName"
        public static let BabyDOB = "babyDOB"
        public static let Email = "email"
        public static let UserID = "userID"
        public static let DesiredMaxSupply = "desiredMaxSupply"
    }

    public struct Defaults {
        public static let DefaultDesiredMaxSupply = 50.0
        public static let BottleTopHeight = 70.0
        public static let BottleFillOverlapWithBottomFillImage = 3.0
    }

    public struct UserDefaultsKeys {
        public static let adsDisplayState = "ads_display_state_key"
    }

    public struct DictionaryKeys {
        public static let VersionNumber = "CFBundleShortVersionString"
        public static let BuildNumber = "CFBundleVersion"
    }
}
