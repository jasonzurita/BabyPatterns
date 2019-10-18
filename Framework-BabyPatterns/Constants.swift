import Foundation

public struct K {
    public struct Segues {
        // app launch
        public static let LoggedIn = "LoggedInSegue"

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
        public static let DefaultDesiredMaxSupply = 2500 // ceniounces
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

    public struct Notifications {
        public static let updateFeedingsUI = NSNotification.Name("com.flippingleaf.notifications.update-feedings-ui")
        public static let showSavedFyiDialog = NSNotification.Name("com.flippingleaf.notifications.show-saved-fyi-dialog")

    }
}
