import Common
import Foundation
import Framework_BabyPatterns
import Library
import WatchConnectivity

extension FeedingsVM: WCSessionDelegate {
    public func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error: Error?) {
        print("Completed activation: \(error?.localizedDescription ?? "n/a error")")
    }

    public func sessionDidBecomeInactive(_: WCSession) {
        print("session did become inactive")
    }

    public func sessionDidDeactivate(_: WCSession) {
        print("session did deactivate")
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let decoder = JSONDecoder()
        guard let info = try? decoder.decode(WatchCommunication.self, from: messageData) else { return }

        guard info.feedingType != .none else { return }
        feedingStarted(type: info.feedingType, side: info.feedingSide)

        // FIXME: for some reason, the UI isn't updating as expected when killed
        let center = NotificationCenter.default
        center.post(name: K.Notifications.updateFeedingsUI, object: nil)
    }
}

final class FeedingsVM: NSObject, Loggable {
    let shouldPrintDebugLog = true
    var feedings: [Feeding] = []

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func loadFeedings(completionHandler: @escaping () -> Void) {
        DatabaseFacade().configureDatabase(requestType: .feedings, responseHandler: { responseArray in
            for response in responseArray {
                self.newPotentialFeeding(json: response.json, serverKey: response.serverKey)
            }
            completionHandler()
        })
    }

    func newPotentialFeeding(json: [String: Any], serverKey: String) {
        guard let feeding = Feeding(json: json, serverKey: serverKey) else { return }
        feedings.append(feeding)
    }
}
