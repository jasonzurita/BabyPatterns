import UIKit

public final class RequestFeatureTVC: UITableViewController {
    private let reuseIdentifier = "requestFeatureCellReuseIdentifier"

    public init() {
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        navigationItem.title = "Request Feature"
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    override public func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let label = UILabel()
        label.text = "Coming soon!"
        label.textAlignment = .center
        cell.addSubview(label)
        label.bindFrameToSuperviewBounds()
        cell.selectionStyle = .none
        return cell
    }
}
