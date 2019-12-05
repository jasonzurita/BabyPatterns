import Swift

enum SavedFyiDialogAction {
    case show
    case hide
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool,
                           action: SavedFyiDialogAction) -> [Effect<SavedFyiDialogAction>] {
    switch action {
    case .show:
        showSavedFyiDialog = true
        return []
    case .hide:
        showSavedFyiDialog = false
        return []
    }
}
