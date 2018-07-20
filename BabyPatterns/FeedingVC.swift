import Framework_BabyPatterns
import Library
import UIKit

struct EndFeedingEvent: Event {
    let endDate: Date
    let type: FeedingType

    init?(date: Date?, type: FeedingType) {
        guard let d = date else { return nil }
        endDate = d
        self.type = type
    }
}

struct FeedingSummary: FeedingSummaryProtocol {
    let timeSinceLastNursing: TimeInterval
    let lastNursingSide: FeedingSide
    let averageNursingDuration: TimeInterval
    let timeSinceLastPumping: TimeInterval
    let lastPumpingSide: FeedingSide
    let lastPumpedAmount: Double
    let timeSinceLastBottleFeeding: TimeInterval
    let remainingSupplyAmount: Double
    let desiredSupplyAmount: Double
}

final class FeedingVC: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    var feedingsVM: FeedingsVM?
    var profileVM: ProfileVM?
    var configuration: Configuration?

    private var _profileImageCoordinator: ProfileImageCoordinator?

    private var notificationToken: NSObjectProtocol?
    private var orderedCompletedFeedingEvents: [Event] {
        guard let vm = feedingsVM else { return [] }
        return vm
            .feedings(withTypes: [.nursing, .bottle, .pumping], isFinished: true)
            .compactMap { EndFeedingEvent(date: $0.endDate, type: $0.type) }
            .sorted { $0.endDate > $1.endDate }
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

        let summary = FeedingSummary(
            timeSinceLastNursing: vm.timeSinceLast(feedingTypes: [.nursing]),
            lastNursingSide: vm.lastFeedingSide(for: .nursing),
            averageNursingDuration: 100,
            timeSinceLastPumping: vm.timeSinceLast(feedingTypes: [.pumping]),
            lastPumpingSide: vm.lastFeedingSide(for: .pumping),
            lastPumpedAmount: vm.lastFeeding(type: .pumping)?.supplyAmount ?? 0,
            timeSinceLastBottleFeeding: vm.timeSinceLast(feedingTypes: [.bottle]),
            remainingSupplyAmount: vm.remainingSupply(),
            desiredSupplyAmount: profileVM?.profile?.desiredMaxSupply ?? K.Defaults.DefaultDesiredMaxSupply
        )
        let vc = HistoryVc(events: orderedCompletedFeedingEvents, summary: summary)
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let vc = segue.destination as? FeedingPageVC {
            configureFeedingPageVC(vc: vc)
        } else if let vc = segue.destination as? SettingsVC, let p = profileVM {
            vc.profileVM = p
            vc.configuration = configuration
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
        toast.presentInView(view: view)
    }
}

extension FeedingVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let controller = PartialSlideInPresentationController(presentedViewController: presented,
                                                              presenting: presenting,
                                                              heightFraction: 0.86)
        return controller
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
    func pumpingAmountChosen(_ amount: Double) {
        feedingsVM?.addPumpingAmountToLastPumping(amount: amount)
        showFeedingSavedToast()
    }
}

extension FeedingVC: BottleDataSource {
    func remainingSupply() -> Double {
        return feedingsVM?.remainingSupply() ?? 0.0
    }

    func desiredMaxSupply() -> Double {
        return profileVM?.profile?.desiredMaxSupply ?? K.Defaults.DefaultDesiredMaxSupply
    }
}

extension FeedingVC: BottleDelegate {
    func logBottleFeeding(withAmount amount: Double, time: Date) {
        // TODO: make specific bottle feeding method for the below weird calls
        feedingsVM?.feedingStarted(type: .bottle, side: .none, startDate: time, supplyAmount: -amount)
        feedingsVM?.feedingEnded(type: .bottle, side: .none, endDate: time)
        showFeedingSavedToast()
    }
}
