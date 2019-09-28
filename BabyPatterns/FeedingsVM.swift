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

    public func session(_: WCSession, didReceiveMessage _: [String: Any]) {
        print("Received message!")
    }

    public func session(_: WCSession,
                        didReceiveMessage message: [String: Any],
                        replyHandler: @escaping ([String: Any]) -> Void) {
        print("message received!")

        guard let m = message as? [String: String] else {
            replyHandler(["response": "poorly formed message"])
            return
        }

        replyHandler(["response": "starting: \(m)"])

        if m["feedingType"] == "nursing" {
            if m["side"] == "left" {
                feedingStarted(type: .nursing, side: .left)
            } else if m["side"] == "right" {
                feedingStarted(type: .nursing, side: .right)
            } else {
                fatalError("No side to start feeding on...")
            }
        } else if m["feedingType"] == "pumping" {
            if m["side"] == "left" {
                feedingStarted(type: .pumping, side: .left)

            } else if m["side"] == "right" {
                feedingStarted(type: .pumping, side: .right)

            } else {
                fatalError("No side to start feeding on...")
            }
        } else {
            // noop for bottle
        }

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
