import Swift

enum AppAction {
    case session(SessionAction)
    case pulse(PulseAction)
    case communication(CommunicationAction)
    case savedFyiDialog(SavedFyiDialogAction)
    case newFeeding(NewFeedingAction)
    case feeding(FeedingAction)
    case context(ContextAction)

    // TODO: consider auto-gen for this:
    // https://github.com/pointfreeco/swift-enum-properties
    var session: SessionAction? {
        get {
            guard case let .session(value) = self else { return nil }
            return value
        }
        set {
            guard case .session = self, let newValue = newValue else { return }
            self = .session(newValue)
        }
    }

    var pulse: PulseAction? {
        get {
            guard case let .pulse(value) = self else { return nil }
            return value
        }
        set {
            guard case .pulse = self, let newValue = newValue else { return }
            self = .pulse(newValue)
        }
    }

    var communication: CommunicationAction? {
        get {
            guard case let .communication(value) = self else { return nil }
            return value
        }
        set {
            guard case .communication = self, let newValue = newValue else { return }
            self = .communication(newValue)
        }
    }

    var savedFyiDialog: SavedFyiDialogAction? {
        get {
            guard case let .savedFyiDialog(value) = self else { return nil }
            return value
        }
        set {
            guard case .savedFyiDialog = self, let newValue = newValue else { return }
            self = .savedFyiDialog(newValue)
        }
    }

    var newFeeding: NewFeedingAction? {
        get {
            guard case let .newFeeding(value) = self else { return nil }
            return value
        }
        set {
            guard case .newFeeding = self, let newValue = newValue else { return }
            self = .newFeeding(newValue)
        }
    }

    var feeding: FeedingAction? {
        get {
            guard case let .feeding(value) = self else { return nil }
            return value
        }
        set {
            guard case .feeding = self, let newValue = newValue else { return }
            self = .feeding(newValue)
        }
    }

    var context: ContextAction? {
        get {
            guard case let .context(value) = self else { return nil }
            return value
        }
        set {
            guard case .context = self, let newValue = newValue else { return }
            self = .context(newValue)
        }
    }
}
