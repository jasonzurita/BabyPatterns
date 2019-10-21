import Foundation

final class Store<Value, Action>: ObservableObject {
    private let reducer: (inout Value, Action) -> Void
    @Published private(set) var value: Value

    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        value = initialValue
    }

    func send(_ action: Action) {
        DispatchQueue.main.async {
            self.reducer(&self.value, action)
        }
    }
}

func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    keyValue: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        reducer(&globalValue[keyPath: keyValue], action)
    }
}
