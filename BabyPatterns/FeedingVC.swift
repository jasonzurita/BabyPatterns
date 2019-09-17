import Framework_BabyPatterns
import Library
import UIKit

struct EndFeedingEvent: Event {
    let endDate: Date
    let type: FeedingType
    let duration: TimeInterval
    let supplyAmount: SupplyAmount

    init?(date: Date?, type: FeedingType, duration: TimeInterval, supplyAmount: SupplyAmount) {
        guard let d = date else { return nil }
        endDate = d
        self.type = type
        self.duration = duration
        self.supplyAmount = supplyAmount
    }
}

struct FeedingSummary: FeedingSummaryProtocol {
    let timeSinceLastNursing: TimeInterval
    let lastNursingSide: FeedingSide
    let averageNursingDuration: (DateInterval) -> TimeInterval
    let timeSinceLastPumping: TimeInterval
    let lastPumpingSide: FeedingSide
    let lastPumpedAmount: SupplyAmount
    let timeSinceLastBottleFeeding: TimeInterval
    let remainingSupplyAmount: SupplyAmount
    let desiredSupplyAmount: SupplyAmount
}

final class FeedingVC: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    var feedingsVM: FeedingsVM?
    var profileVM: ProfileVM?

    private var _profileImageCoordinator: ProfileImageCoordinator?

    private var notificationToken: NSObjectProtocol?
    private var orderedCompletedFeedingEvents: [Event] {
        guard let vm = feedingsVM else { return [] }
        return vm
            .feedings(withTypes: [.nursing, .bottle, .pumping], isFinished: true)
            .compactMap { EndFeedingEvent(date: $0.endDate,
                                          type: $0.type,
                                          duration: $0.duration(),
                                          supplyAmount: $0.supplyAmount) }
            .sorted { $0.endDate > $1.endDate }
    }

    @IBOutlet var showHistoryButton: UIButton! {
        didSet {
            showHistoryButton.setTitle("History", for: .normal)
            styleButtonCircle(showHistoryButton)
        }
    }

    @IBOutlet var segmentedControl: SegmentedControlBar!
    @IBOutlet var profileView: ProfileView! {
        didSet {
            profileView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.title = " "
        let titles = FeedingType.allValues.map { $0.rawValue }
        segmentedControl.configureSegmentedBar(titles: titles, defaultSegmentIndex: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfileUI()
    }

    private func updateProfileUI() {
        guard let p = profileVM?.profile else { return }
        profileView.nameLabel.text = p.babyName
        navigationItem.title = "Welcome \(p.parentName)!"
        let image = p.profilePicture ?? UIImage(named: "defaultProfileImage")
        profileView.imageView.image = image

        let babyDOBInSeconds = p.babyDOB.timeIntervalSinceNow
        let wasBabyBorn = babyDOBInSeconds <= 0
        if wasBabyBorn {
            let secondsInAWeek: Double = 7 * 24 * 60 * 60
            let numberOfWeeks = Int(abs(babyDOBInSeconds) / secondsInAWeek)
            profileView.ageLabel.text = "\(numberOfWeeks) weeks"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    @IBAction func showHistoryButtonPressed(_: UIButton) {
        guard let vm = feedingsVM else {
            fatalError("No feedingsVM to show history screen with")
        }

        let defaultMax = SupplyAmount(value: K.Defaults.DefaultDesiredMaxSupply)
        let summary = FeedingSummary(
            timeSinceLastNursing: vm.timeSinceLast(feedingTypes: [.nursing]),
            lastNursingSide: vm.lastFeedingSide(for: .nursing),
            averageNursingDuration: vm.averageNursingDuration,
            timeSinceLastPumping: vm.timeSinceLast(feedingTypes: [.pumping]),
            lastPumpingSide: vm.lastFeedingSide(for: .pumping),
            lastPumpedAmount: vm.lastFeeding(type: .pumping)?.supplyAmount ?? SupplyAmount.zero,
            timeSinceLastBottleFeeding: vm.timeSinceLast(feedingTypes: [.bottle]),
            remainingSupplyAmount: vm.remainingSupply(),
            desiredSupplyAmount: profileVM?.profile?.desiredMaxSupply ?? defaultMax
        )
        let vc = HistoryVc(events: orderedCompletedFeedingEvents, summary: summary)
        present(vc, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let vc = segue.destination as? FeedingPageVC {
            configureFeedingPageVC(vc: vc)
        } else if let vc = segue.destination as? SettingsVC, let p = profileVM {
            vc.profileVM = p
        }
    }

    private func configureFeedingPageVC(vc: FeedingPageVC) {
        segmentedControl.delegate = vc
        vc.segmentedControl = segmentedControl

        let page1 = NursingVC(controller: self)
        if let lf = feedingsVM?.lastFeeding(type: .nursing), !lf.isFinished {
            page1.resume(feeding: lf)
        }
        let page2 = PumpingVC(controller: self)
        if let lf = feedingsVM?.lastFeeding(type: .pumping), !lf.isFinished {
            page2.resume(feeding: lf)
        }
        let page3 = BottleVC()
        page3.delegate = self
        page3.dataSource = self
        vc.pages.append(contentsOf: [page1, page2, page3])
    }

    @IBAction func unwindToFeedingVC(segue _: UIStoryboardSegue) {}

    fileprivate func showFeedingSavedToast() {
        let toastSize: CGFloat = 150
        let frame = CGRect(x: view.frame.width * 0.5 - (toastSize * 0.5),
                           y: view.frame.height * 0.5 - (toastSize * 0.5),
                           width: toastSize,
                           height: toastSize)

        let toast = Toast(frame: frame, text: "Saved!")
        styleLabelToast(toast)
        toast.present(in: view)
    }
}

extension FeedingVC: ProfileViewDelegate {
    func changeProfileImageButtonTapped() {
        let coordinator = ProfileImageCoordinator(rootVc: self)
        defer { _profileImageCoordinator = coordinator }

        coordinator.onImageChosen = { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.profileVM?.updateProfilePhoto(image: image)
            strongSelf.updateProfileUI()
            strongSelf._profileImageCoordinator = nil
        }
        coordinator.changeProfileImageButtonTapped()
    }
}

extension FeedingVC: FeedingController {
    func lastFeedingSide(type: FeedingType) -> FeedingSide {
        guard let vm = feedingsVM else { return .none }
        return vm.lastFeedingSide(for: type)
    }

    func start(feeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.feedingStarted(type: type, side: side)
    }

    func end(feeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.feedingEnded(type: type, side: side)
        showFeedingSavedToast()
    }

    // TODO: split up feedingVM.updateFeedingInProgress for pause and resume
    func pause(feeeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.updateFeedingInProgress(type: type, side: side, isPaused: true)
    }

    func resume(feeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.updateFeedingInProgress(type: type, side: side, isPaused: false)
    }
}

extension FeedingVC: PumpingActionProtocol {
    // TODO: if using other units this function should take units in
    func pumpingAmountChosen(_ amount: SupplyAmount) {
        feedingsVM?.addPumpingAmountToLastPumping(amount: amount)
        showFeedingSavedToast()
    }
}

extension FeedingVC: BottleDataSource {
    func remainingSupply() -> SupplyAmount {
        return feedingsVM?.remainingSupply() ?? SupplyAmount.zero
    }

    func desiredMaxSupply() -> SupplyAmount {
        let max = SupplyAmount(value: K.Defaults.DefaultDesiredMaxSupply)
        return profileVM?.profile?.desiredMaxSupply ?? max
    }
}

extension FeedingVC: BottleDelegate {
    func logBottleFeeding(withAmount amount: Int, time: Date) {
        // TODO: make specific bottle feeding method for the below weird calls
        // TODO: if using other units this function should take units in
        let supplyAmount = SupplyAmount(value: -amount)
        feedingsVM?.feedingStarted(type: .bottle, side: .none, startDate: time, supplyAmount: supplyAmount)
        feedingsVM?.feedingEnded(type: .bottle, side: .none, endDate: time)
        showFeedingSavedToast()
    }
}
