import Common
import Foundation
import WatchConnectivity
import Framework_BabyPatterns

extension FeedingsVM {
    func feedingStarted(type: FeedingType,
                        side: FeedingSide,
                        startDate: Date = Date(),
                        supplyAmount: SupplyAmount = SupplyAmount.zero) {
        // FIXME: I dislike that you can start a feeding of type none...
        // FIXME: there is a bug here in that after there is more than one feeding this
        // will always let you start another
        guard feedingInProgress(type: type) == nil else {
            log("Already a feeding started of this type...", object: self, type: .warning)
            return
        }

        var fip = Feeding(type: type, side: side, startDate: startDate, supplyAmount: supplyAmount)
        let serverKey = DatabaseFacade().uploadJSON(fip.eventJson(), requestType: .feedings)
        fip.serverKey = serverKey
        feedings.append(fip)

        if type != .bottle {
            communicate(feeding: fip, action: .start)
        }
    }

    // TODO: the term `feeding in progress` doesn't quite fit here, consider improving naming
    func addPumpingAmountToLastPumping(amount: SupplyAmount) {
        guard let lpf = feedings.reversed().first(where: { $0.type == .pumping }) else {
            log("No pumping to to add amount to...", object: self, type: .warning)
            return
        }

        // TODO: more of a swift excercise, but there should be a better way to
        // duplicate a struct and update one property. Maybe make an update function?
        let updatedPumpingFeeding = Feeding(type: lpf.type,
                                            side: lpf.side,
                                            startDate: lpf.startDate,
                                            endDate: lpf.endDate,
                                            lastPausedDate: lpf.lastPausedDate,
                                            supplyAmount: amount,
                                            pausedTime: lpf.pausedTime,
                                            serverKey: lpf.serverKey)

        updateInternalFeedingCache(fip: updatedPumpingFeeding)
        updateFeedingOnServer(fip: updatedPumpingFeeding)
    }

    func feedingEnded(type: FeedingType, side _: FeedingSide, endDate: Date = Date()) {
        guard var fip = feedingInProgress(type: type) else { return }

        fip.endDate = endDate
        fip.lastPausedDate = nil

        updateInternalFeedingCache(fip: fip)
        updateFeedingOnServer(fip: fip)

        if type != .bottle {
            communicate(feeding: fip, action: .stop)
        }
    }

    func updateFeedingInProgress(type: FeedingType, side _: FeedingSide, isPaused: Bool) {
        guard var fip = feedingInProgress(type: type) else { return }

        if isPaused {
            fip.lastPausedDate = Date()
        } else if let lastPausedDate = fip.lastPausedDate {
            fip.pausedTime += abs(lastPausedDate.timeIntervalSinceNow)
            fip.lastPausedDate = nil
        }

        updateInternalFeedingCache(fip: fip)
        updateFeedingOnServer(fip: fip)

        if type != .bottle {
            let action: FeedingAction = isPaused ? .pause : .resume
            communicate(feeding: fip, action: action)
        }
    }

    private func updateInternalFeedingCache(fip: Feeding) {
        // TODO: implement an == definition in the Feeding class to make this more robust
        if let i = feedings.firstIndex(where: { $0.serverKey == fip.serverKey }) {
            feedings[i] = fip
        }
    }

    private func updateFeedingOnServer(fip: Feeding) {
        guard let serverKey = fip.serverKey else {
            log("Did not update feeding on server because no server key found...", object: self, type: .error)
            return
        }
        DatabaseFacade().updateJSON(fip.eventJson(), serverKey: serverKey, requestType: .feedings)
    }

    func feedingInProgress(type: FeedingType) -> Feeding? {
        let f = feedings.filter { $0.type == type && !$0.isFinished }
        guard !f.isEmpty else { return nil }
        guard f.count == 1, let feeding = f.first else {
            log("More than one in-progress feeding of the same type...", object: self, type: .warning)
            return nil
        }
        return feeding
    }

    // TODO: consider making this a global function or ?
    // This is the third time copying and pasting this, but first time in this target
    func communicate(feeding: Feeding, action: Common.FeedingAction) {
        let info = WatchCommunication(type: feeding.type, side: feeding.side, action: action)

        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            // TODO: show communication error?
            return
        }

        WCSession.default.sendMessageData(
            d,
            replyHandler: { _ in /* noop */ },
            errorHandler: { error in
                // TODO: show communication error
                print("Error sending the message: \(error.localizedDescription)")
        })
    }
}
