import Swift

enum SavedFyiDialogAction {
    case show
    case hide
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool, action: SavedFyiDialogAction) {
    switch action {
    case .show:
        showSavedFyiDialog = true
    case .hide:
        showSavedFyiDialog = false
    }
}
