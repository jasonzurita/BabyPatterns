import Common
import Foundation
import WatchConnectivity

enum ContextAction {
    case requestFullContext
    case fullContextRequestFailed
}

func contextReducer(showCommunicationErrorFyiDialog: inout Bool, action: ContextAction) -> [Effect<ContextAction>] {
    switch action {
    case .requestFullContext:
        return [ { callback in
            let communication = WatchContextCommunication()
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(communication) else { return }
            WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: { _ in
                callback(.fullContextRequestFailed)
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
