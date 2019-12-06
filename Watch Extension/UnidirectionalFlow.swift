import Foundation
import Combine

typealias Effect<Action> = (@escaping (Action) -> Void) -> Void

typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action>
    @Published private(set) var value: Value
    private var cancellable: Cancellable?

    init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.reducer = reducer
        value = initialValue
    }

    func send(_ action: Action) {
        DispatchQueue.main.async {
            let effects = self.reducer(&self.value, action)
            effects.forEach { effect in
                effect(self.send)
            }
        }
    }

    func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}

func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}

func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        let globalEffects: [Effect<GlobalAction>] = localEffects.map { localEffect in
            // swiftlint:disable opening_brace
            { callback in
            // swiftlint:enable opening_brace
                localEffect { localAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    callback(globalAction)
                }
            }
        }
        return globalEffects
    }
}

func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [{ _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
    }] + effects
  }
}
