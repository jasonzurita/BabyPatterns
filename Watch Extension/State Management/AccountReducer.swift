import Swift

enum SessionState {
    case loggedIn
    case loggedOut
}

enum SessionAction {
    case loggedIn
    case loggedOut
}

func accountStatusReducer(sessionState: inout SessionState, action: SessionAction) {
    switch action {
    // TODO: can logged out and logged in be combined?
    case .loggedIn:
        sessionState = .loggedIn
    case .loggedOut:
        sessionState = .loggedOut
    }
}
