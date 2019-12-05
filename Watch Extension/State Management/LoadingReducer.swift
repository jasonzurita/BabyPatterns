import Swift

enum LoadingAction {
    case loading
    case notLoading
}

func loadingReducer(isLoading: inout Bool,
                    action: LoadingAction) -> [Effect<LoadingAction>] {
    switch action {
    case .loading:
        isLoading = true
        return []
    case .notLoading:
        isLoading = false
        return []
    }
}
