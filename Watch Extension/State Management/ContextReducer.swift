import Common
import Foundation
import WatchConnectivity

enum ContextAction {
    case requestFullContext
}

// TODO: need to figure out how to remove the state from here since
// there is no need to have it at all. This reducer is to just formalize
// an action
func contextReducer(state _: inout AppState, action: ContextAction) -> [Effect<ContextAction>] {
    switch action {
    case .requestFullContext:
        let communication = WatchContextCommunication()
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(communication) else { return [] }
        WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        return []
    }
}
