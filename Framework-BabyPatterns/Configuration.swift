import Foundation

public enum AdsDisplayState: String {
    case show, hide, initialInstall
}

public struct Configuration {
    private let _defaults: UserDefaults
    public var adsState: AdsDisplayState {
        set {
            _defaults.set(newValue.rawValue, forKey: K.UserDefaultsKeys.adsDisplayState)
        }
        get {
            guard let stateString = _defaults.string(forKey: K.UserDefaultsKeys.adsDisplayState) else {
                return .initialInstall
            }
            guard let state = AdsDisplayState(rawValue: stateString) else {
                fatalError("Invalid string stored for ads display state: \(stateString)")
            }
            return  state
        }
    }

    public init(defaults: UserDefaults) {
        _defaults = defaults
    }
}
