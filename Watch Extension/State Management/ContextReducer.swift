import Common
import Cycle
import Foundation
import WatchConnectivity

enum ContextAction {
    case requestFullContext
    case fullContextRequest(Data?)

}

func contextReducer(showCommunicationErrorFyiDialog: inout Bool, action: ContextAction) -> [Effect<ContextAction>] {
    switch action {
    case .requestFullContext:
        let communication = WatchContextCommunication()
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(communication) else { return [] }

        return [
            WCSession.sendMessageDataPublisher(data: data)
                .compactMap { $0 }
                .replaceError(with: nil)
                .map (ContextAction.fullContextRequest)
                .receive(on: DispatchQueue.main)
                .eraseToEffect(),
        ]
    case let .fullContextRequest(data):
        showCommunicationErrorFyiDialog = data == nil
        return []
    }
}
