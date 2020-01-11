import Foundation
import Combine

public struct Effect<Output>: Publisher {
    public typealias Failure = Never

    private let anyPublisher: AnyPublisher<Output, Never>

    public init(_ publisher: AnyPublisher<Output, Never>) {
        self.anyPublisher = publisher
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        anyPublisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        Effect(self.eraseToAnyPublisher())
    }
}

extension Effect {
    public static func fireAndForget(_ work: @escaping () -> Void) -> Effect {
        Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToEffect()
    }
}

extension Effect {
    public static func sync(_ work: @escaping () -> Output) -> Effect {
        Deferred {
            Just(work())
        }.eraseToEffect()
    }
}
