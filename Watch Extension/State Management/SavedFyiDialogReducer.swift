import Swift
import Cycle

// TODO: delete this action by moving the hide functinality into side effects

enum SavedFyiDialogAction {
    case hide
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool,
                           action: SavedFyiDialogAction) -> [Effect<SavedFyiDialogAction>] {
    switch action {
    case .hide:
        showSavedFyiDialog = false
        return []
    }
}
