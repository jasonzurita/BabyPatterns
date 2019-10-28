import Common
import Foundation
import Framework_BabyPatterns
import Library

final class FeedingsVM: NSObject, Loggable {
    let shouldPrintDebugLog = true
    var feedings: [Feeding] = []

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
