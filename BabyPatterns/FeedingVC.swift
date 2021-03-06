import Common
import Framework_BabyPatterns
import Library
import UIKit

struct EndedFeedingEvent: Event {
    let startDate: Date
    let type: FeedingType
    let side: FeedingSide
    let duration: TimeInterval
    let supplyAmount: SupplyAmount

    init?(startDate: Date,
          type: FeedingType,
          side: FeedingSide,
          duration: TimeInterval,
          supplyAmount: SupplyAmount
    ) {
        self.startDate = startDate
        self.type = type
        self.side = side
        self.duration = duration
        self.supplyAmount = supplyAmount
    }
}

struct FeedingSummary: FeedingSummaryProtocol {
    let timeSinceLastStart: ([FeedingType]) -> TimeInterval
    let lastNursingSide: FeedingSide
    let averageNursingDuration: (DateInterval) -> TimeInterval
    let lastPumpingSide: FeedingSide
    let lastPumpedAmount: SupplyAmount
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
            .compactMap { EndedFeedingEvent(startDate: $0.startDate,
                                          type: $0.type,
                                          side: $0.side,
                                          duration: $0.duration(),
                                          supplyAmount: $0.supplyAmount) }
            .sorted { $0.startDate > $1.startDate }
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

        let center = NotificationCenter.default
        notificationToken = center.addObserver(forName: K.Notifications.updateFeedingsUI,
                                               object: nil,
                                               queue: nil) { _ in
            if let lf = self.feedingsVM?.lastFeeding(type: .nursing) {
                DispatchQueue.main.async {
                    self.nVc?.resume(feeding: lf)
                }
            }
            if let lf = self.feedingsVM?.lastFeeding(type: .pumping) {
                DispatchQueue.main.async {
                    self.pVc?.resume(feeding: lf)
                }
            }
        }

        center.addObserver(self,
                           selector: #selector(showFeedingSavedFyiDialog),
                           name: K.Notifications.showSavedFyiDialog,
                           object: nil)
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
            timeSinceLastStart: vm.timeSinceLastFeedingStart(for:),
            lastNursingSide: vm.lastFeedingSide(for: .nursing),
            averageNursingDuration: vm.averageNursingDuration,
            lastPumpingSide: vm.lastFeedingSide(for: .pumping),
            lastPumpedAmount: vm.lastFeeding(type: .pumping)?.supplyAmount ?? SupplyAmount.zero,
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

    private var nVc: NursingVC?
    private var pVc: PumpingVC?

    private func configureFeedingPageVC(vc: FeedingPageVC) {
        segmentedControl.delegate = vc
        vc.segmentedControl = segmentedControl

        let page1 = NursingVC(controller: self)
        if let lf = feedingsVM?.lastFeeding(type: .nursing), !lf.isFinished {
            page1.resume(feeding: lf)
        }
        nVc = page1
        let page2 = PumpingVC(controller: self)
        if let lf = feedingsVM?.lastFeeding(type: .pumping), !lf.isFinished {
            page2.resume(feeding: lf)
        }
        pVc = page2
        let page3 = BottleVC()
        page3.delegate = self
        page3.dataSource = self
        vc.pages.append(contentsOf: [page1, page2, page3])
    }

    @IBAction func unwindToFeedingVC(segue _: UIStoryboardSegue) {}

    @objc fileprivate func showFeedingSavedFyiDialog() {
        let dialogSize: CGFloat = 150
        let frame = CGRect(x: view.frame.width * 0.5 - (dialogSize * 0.5),
                           y: view.frame.height * 0.5 - (dialogSize * 0.5),
                           width: dialogSize,
                           height: dialogSize)

        let fyi = FyiDialog(frame: frame, text: "Saved!")
        styleLabelFyiDialog(fyi)
        fyi.present(in: view)
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
        showFeedingSavedFyiDialog()
    }

    // TODO: split up feedingVM.updateFeedingInProgress for pause and resume
    func pause(feeeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.updateFeedingInProgress(type: type, side: side, isPaused: true)
    }

    func resume(feeding type: FeedingType, side: FeedingSide) {
        feedingsVM?.updateFeedingInProgress(type: type, side: side, isPaused: false)
    }

    func feedingInProgress(type: FeedingType) -> Feeding? {
        feedingsVM?.feedingInProgress(type: type)
    }
}

extension FeedingVC: PumpingActionProtocol {
    // TODO: if using other units this function should take units in
    func pumpingAmountChosen(_ amount: SupplyAmount) {
        feedingsVM?.addPumpingAmountToLastPumping(amount: amount)
        showFeedingSavedFyiDialog()
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
        showFeedingSavedFyiDialog()
    }
}
