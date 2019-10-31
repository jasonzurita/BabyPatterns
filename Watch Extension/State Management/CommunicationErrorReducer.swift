import Swift

enum CommunicationErrorFyiDialogAction {
    case show
    case hide
}

func communicationErrorFyiDialogReducer(showCommunicationFyiDialog: inout Bool,
                                        action: CommunicationErrorFyiDialogAction) {
    switch action {
    case .show:
        showCommunicationFyiDialog = true
    case .hide:
        showCommunicationFyiDialog = false
    }
}
