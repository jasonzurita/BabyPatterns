import Common
import Cycle
import Foundation
import WatchConnectivity

enum ContextAction {
    case requestFullContext
    case fullContextRequestFailed
}

func contextReducer(showCommunicationErrorFyiDialog: inout Bool, action: ContextAction) -> [Effect<ContextAction>] {
    switch action {
    case .requestFullContext:
        let communication = WatchContextCommunication()
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(communication) else { return [] }
        
        return [
            Effect { callback in
                WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: { _ in
                    DispatchQueue.main.async { callback(.fullContextRequestFailed) }
                })
            },
        ]
    case .fullContextRequestFailed:
        showCommunicationErrorFyiDialog = true
        // TODO: we can formalize the removal of the fyi dialog here with a
        // side effect dispatch async and a new action!
        return []
    }
}
