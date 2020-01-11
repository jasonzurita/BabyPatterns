import Combine
import WatchConnectivity
import Cycle

extension WCSession {
    static func sendMessageDataPublisher(
        data: Data,
        using session: WCSession = WCSession.default
    ) -> Future<Data, Error> {
        Future { promise in
            session.sendMessageData(
                data,
                replyHandler: { d in
                    promise(.success(d))
            },
                errorHandler: { error in
                    promise(.failure(error))
            })
        }
    }
}
