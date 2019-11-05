import Swift

enum LoadingAction {
    case loading
    case notLoading
}

func loadingReducer(isLoading: inout Bool,
                    action: LoadingAction) {
    switch action {
    case .loading:
        isLoading = true
    case .notLoading:
        isLoading = false
    }
}
