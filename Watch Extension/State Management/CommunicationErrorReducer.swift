import Swift

// TODO: delete this action by moving the hide functinality into side effects

enum CommunicationErrorFyiDialogAction {
    case hide
}

func communicationErrorFyiDialogReducer(
    showCommunicationFyiDialog: inout Bool,
    action: CommunicationErrorFyiDialogAction
) -> [Effect<CommunicationErrorFyiDialogAction>] {
    switch action {
    case .hide:
        showCommunicationFyiDialog = false
        return []
    }
}
