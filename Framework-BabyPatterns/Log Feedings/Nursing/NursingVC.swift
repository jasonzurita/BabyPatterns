
//public final class NursingVC: UIViewController, Loggable {
//
//    override public func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        resumeFeedingIfNeeded()
//    }
//
//    private func resumeFeedingIfNeeded() {
//        guard let lf = dataSource?.lastFeeding(type: feedingType), !lf.isFinished else {
//            timerLabel.changeDisplayTime(time: 0)
//            return
//        }
//
//        guard let control = lf.side == .left ? leftFeedingControl : rightFeedingControl else {
//            log("No active control to resume feeding with", object: self, type: .error)
//            return
//        }
//        resumeFeeding(feedingInProgress: lf, activeControl: control)
//    }
//
//    private func resumeFeeding(feedingInProgress: Feeding, activeControl: FeedingControl) {
//        startFeeding(control: activeControl, startTime: feedingInProgress.duration())
//        if feedingInProgress.isPaused {
//            pauseFeeding(control: activeControl)
//        }
//    }
//
//    @IBAction func editLastFeeding(_: UIButton) {
//    }
//}
//
//
