import Swift

enum AppAction {
    case session(SessionAction)
    case pulse(PulseAction)
    case fyiDialog(SavedFyiDialogAction)
    case communicationErrorFyiDialog(CommunicationErrorFyiDialogAction)
    case feeding(FeedingAction)
    case context(ContextAction)
    case loading(LoadingAction)

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

    var savedFyiDialog: SavedFyiDialogAction? {
        get {
            guard case let .fyiDialog(value) = self else { return nil }
            return value
        }
        set {
            guard case .fyiDialog = self, let newValue = newValue else { return }
            self = .fyiDialog(newValue)
        }
    }

    var communicationErrorFyiDialog: CommunicationErrorFyiDialogAction? {
        get {
            guard case let .communicationErrorFyiDialog(value) = self else { return nil }
            return value
        }
        set {
            guard case .communicationErrorFyiDialog = self, let newValue = newValue else { return }
            self = .communicationErrorFyiDialog(newValue)
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

    var loading: LoadingAction? {
        get {
            guard case let .loading(value) = self else { return nil }
            return value
        }
        set {
            guard case .loading = self, let newValue = newValue else { return }
            self = .loading(newValue)
        }
    }
}
