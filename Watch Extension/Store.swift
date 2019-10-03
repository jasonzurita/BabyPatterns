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
