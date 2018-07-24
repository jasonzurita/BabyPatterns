import Swift

public enum Units {
    case centiounces
    case ounces
}

public struct SupplyAmount {
    public let value: Int
    public let units: Units

    /**
     Designated initializer
     - parameter value: the amount pumped or fed
     - parameter units: the units for the above value
     The default is `.centiounce` because that is the
     base unit for this app internally. If another unit
     is provided here, it will be converted to centiounces.
     */
    public init(value: Int, units: Units = .centiounces) {
        self.value = SupplyAmount.adjust(value: value, for: units)
        self.units = units
    }

    // TODO: maybe change the name of value to centiounces to be clear what the base is
    private static func adjust(value: Int, for units: Units) -> Int {
        var adjustedValue = value
        switch units {
        case .centiounces:
            break
        case .ounces:
            adjustedValue = value * 10
        }
        return adjustedValue
    }

    public static var zero: SupplyAmount {
        return SupplyAmount(value: 0)
    }

    public static func + (left: SupplyAmount, right: SupplyAmount) -> SupplyAmount {
        guard left.units == right.units else {
            fatalError("Unable to add supply amounts with different units")
        }
        let newValue = left.value + right.value
        return SupplyAmount(value: newValue, units: left.units)
    }

    public static func - (left: SupplyAmount, right: SupplyAmount) -> SupplyAmount {
        guard left.units == right.units else {
            fatalError("Unable to add supply amounts with different units")
        }
        let newValue = left.value - right.value
        return SupplyAmount(value: newValue, units: left.units)
    }

}

// MARK: Display
extension SupplyAmount {
    public func displayValue(for u: Units) -> String {
        switch u {
        case .centiounces:
            return "\(value)"
        case .ounces:
            // TOOD: consider pulling the 0.01 out into the enum
            return "\(Double(value) * 0.01)"
        }
    }
    public func displayUnits(for u: Units) -> String {
        switch u {
        case .centiounces:
            return "coz"
        case .ounces:
            return "oz"
        }
    }
    public func displayText(for units: Units) -> String {
        return "\(displayValue(for: units)) \(displayUnits(for: units))"
    }
}
