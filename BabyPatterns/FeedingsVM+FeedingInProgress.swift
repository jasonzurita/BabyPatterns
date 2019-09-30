import Common
import Foundation
import Framework_BabyPatterns

extension FeedingsVM {
    func feedingStarted(type: FeedingType,
                        side: FeedingSide,
                        startDate: Date = Date(),
                        supplyAmount: SupplyAmount = SupplyAmount.zero) {
        guard feedingInProgress(type: type) == nil else {
            log("Already a feeding started of this type...", object: self, type: .warning)
            return
        }

        var fip = Feeding(type: type, side: side, startDate: startDate, supplyAmount: supplyAmount)
        let serverKey = DatabaseFacade().uploadJSON(fip.eventJson(), requestType: .feedings)
        fip.serverKey = serverKey
        feedings.append(fip)
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
        guard f.count > 0 else { return nil }
        guard f.count == 1, let feeding = f.first else {
            log("More than one in-progress feeding of the same type...", object: self, type: .warning)
            return nil
        }
        return feeding
    }
}
