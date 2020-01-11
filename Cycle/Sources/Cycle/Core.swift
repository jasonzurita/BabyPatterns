import Foundation
import Combine

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellers: Set<AnyCancellable> = []

    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.reducer = reducer
        value = initialValue
    }

    public func send(_ action: Action) {
        let effects = self.reducer(&self.value, action)
        effects.forEach { effect in
            var canceller: AnyCancellable?
            var didComplete = false
            canceller = effect.sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    guard let c = canceller else { return }
                    self?.effectCancellers.remove(c)
            },
                receiveValue: self.send
            )
            if !didComplete, let c = canceller {
                effectCancellers.insert(c)
            }
        }
    }

    public func view<LocalValue, LocalAction>(
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
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}

public func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}

public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        let globalEffects: [Effect<GlobalAction>] = localEffects.map { localEffect in
            localEffect.map { localAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }.eraseToEffect()
        }
        return globalEffects
    }
}

public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [
            .fireAndForget {
                print("Action: \(action)")
                print("Value:")
                dump(newValue)
                print("---")
            },
            ] + effects
    }
}
