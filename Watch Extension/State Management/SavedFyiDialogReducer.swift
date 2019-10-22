import Swift

enum SavedFyiDialogAction {
    case hideSavedFyiDialog
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool, action: SavedFyiDialogAction) {
    switch action {
    case .hideSavedFyiDialog:
        showSavedFyiDialog = false
    }
}
