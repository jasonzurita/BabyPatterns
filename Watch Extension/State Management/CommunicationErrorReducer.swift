import Swift

enum CommunicationErrorFyiDialogAction {
    case show
    case hide
}

func communicationErrorFyiDialogReducer(
    showCommunicationFyiDialog: inout Bool,
    action: CommunicationErrorFyiDialogAction
) -> [Effect<CommunicationErrorFyiDialogAction>] {
    switch action {
    case .show:
        showCommunicationFyiDialog = true
        return []
    case .hide:
        showCommunicationFyiDialog = false
        return []
    }
}
