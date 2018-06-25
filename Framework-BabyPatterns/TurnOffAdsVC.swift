import UIKit

public final class TurnOffAdsVC: UIViewController {
    public init() {
        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self)))
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismissButtonTapped(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
