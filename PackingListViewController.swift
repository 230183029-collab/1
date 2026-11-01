import UIKit

/// "Packing" tab: a sectioned checklist in a UITableView.
final class PackingListViewController: UIViewController {

    // MARK: State & views

    private let store = PackingStore.shared
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let headerContainer = UIView()
    private let progressLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Packing List"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .always

        configureTableView()
        configureHeader()
        configureNavigationItems()
        updateHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Suggestions may have been added from the Explore tab.
        tableView.reloadData()
        updateHeader()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // MARK: Setup

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PackingItemCell.self, forCellReuseIdentifier: PackingItemCell.reuseID)
        tableView.register(CategoryHeaderView.self, forHeaderFooterViewReuseIdentifier: CategoryHeaderView.reuseID)
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 28
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureHeader() {
        headerContainer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 72)
        headerContainer.autoresizingMask = [.flexibleWidth]

        progressLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        progressView.progressTintColor = Theme.accent
        progressView.trackTintColor = .systemFill
        progressView.translatesAutoresizingMaskIntoConstraints = false

        headerContainer.addSubview(progressLabel)
        headerContainer.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 10),
            progressLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),

            progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20)
        ])

        tableView.tableHeaderView = headerContainer
    }

    private func configureNavigationItems() {
        navigationItem.leftBarButtonItem = editButtonItem

        let addActions = PackingCategory.allCases.map { category in
            UIAction(title: category.rawValue, image: UIImage(systemName: category.symbol)) { [weak self] _ in
                self?.presentAddAlert(for: category)
            }
        }
        let addButton = UIBarButtonItem(systemItem: .add,
                                        primaryAction: nil,
                                        menu: UIMenu(title: "Add to…", children: addActions))

        let unpackAll = UIAction(title: "Unpack Everything", image: UIImage(systemName: "arrow.uturn.backward")) { [weak self] _ in
            self?.store.unpackAll()
            self?.tableView.reloadData()
            self?.updateHeader()
        }
        let removePacked = UIAction(title: "Remove Packed Items",
                                    image: UIImage(systemName: "trash"),
                                    attributes: .destructive) { [weak self] _ in
            self?.store.removePacked()
            self?.tableView.reloadData()
            self?.updateHeader()
        }
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         menu: UIMenu(children: [unpackAll, removePacked]))

        navigationItem.rightBarButtonItems = [addButton, moreButton]
    }

    // MARK: Helpers

    private func updateHeader() {
        let total = store.totalCount
        let packed = store.packedCount
        progressLabel.text = total == 0 ? "Your suitcase is empty" : "\(packed) of \(total) items packed"
        progressView.setProgress(total == 0 ? 0 : Float(packed) / Float(total), animated: true)
    }

    private func footerText(for section: Int) -> String {
        let items = store.sections[section]
        if items.isEmpty { return "Nothing here yet. Tap + to add something." }
        let packed = items.filter { $0.isPacked }.count
        return "\(packed) of \(items.count) packed"
    }

    /// Footers come from `titleForFooterInSection`, so refresh the visible one in place.
    private func refreshFooter(in section: Int) {
        guard let footer = tableView.footerView(forSection: section) else { return }
        footer.textLabel?.text = footerText(for: section)
        footer.setNeedsLayout()
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    private func togglePacked(at indexPath: IndexPath) {
        store.toggle(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .fade)
        refreshFooter(in: indexPath.section)
        updateHeader()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func deleteItem(at indexPath: IndexPath) {
        store.remove(at: indexPath)
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            self?.refreshFooter(in: indexPath.section)
        })
        updateHeader()
    }

    private func changeQuantity(at indexPath: IndexPath, by delta: Int) {
        store.adjustQuantity(at: indexPath, by: delta)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // MARK: Alerts

    private func presentAddAlert(for category: PackingCategory) {
        let alert = UIAlertController(title: "New \(category.rawValue) Item", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Item name"
            field.autocapitalizationType = .sentences
        }
        alert.addTextField { field in
            field.placeholder = "Quantity (default 1)"
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            let name = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            let quantity = Int(alert?.textFields?[1].text ?? "") ?? 1
            let item = PackingItem(title: name,
                                   category: category,
                                   quantity: max(1, min(quantity, 99)),
                                   isPacked: false,
                                   note: "")
            let indexPath = self.store.add(item)
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            self.updateHeader()
        })
        present(alert, animated: true)
    }

    private func presentNoteAlert(at indexPath: IndexPath) {
        let item = store.item(at: indexPath)
        let alert = UIAlertController(title: item.title, message: "Add a short reminder for this item.", preferredStyle: .alert)
        alert.addTextField { field in
            field.text = item.note
            field.placeholder = "e.g. Charge the night before"
            field.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self?.store.setNote(text, at: indexPath)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PackingListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return PackingCategory.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PackingItemCell.reuseID,
                                                       for: indexPath) as? PackingItemCell else {
            return UITableViewCell()
        }
        cell.configure(with: store.item(at: indexPath))
        return cell
    }

    /// "3 of 4 packed" summary under each category.
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footerText(for: section)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /// Handles the delete control shown in edit mode.
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        store.move(from: sourceIndexPath, to: destinationIndexPath)
    }
}

// MARK: - UITableViewDelegate

extension PackingListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeaderView.reuseID)
                as? CategoryHeaderView else {
            return nil
        }
        header.configure(category: PackingCategory.allCases[section], count: store.sections[section].count)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    /// Rows with a note need room for a second line.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return store.item(at: indexPath).note.isEmpty ? 56 : 68
    }

    /// Tapping a row packs or unpacks the item.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        togglePacked(at: indexPath)
    }

    /// Swipe left: delete or attach a note.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteItem(at: indexPath)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")

        let note = UIContextualAction(style: .normal, title: "Note") { [weak self] _, _, completion in
            self?.presentNoteAlert(at: indexPath)
            completion(true)
        }
        note.image = UIImage(systemName: "square.and.pencil")
        note.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [delete, note])
    }

    /// Swipe right: quick pack / unpack, and a full swipe performs it.
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isPacked = store.item(at: indexPath).isPacked
        let action = UIContextualAction(style: .normal, title: isPacked ? "Unpack" : "Pack") { [weak self] _, _, completion in
            self?.togglePacked(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: isPacked ? "arrow.uturn.backward" : "checkmark")
        action.backgroundColor = isPacked ? .systemGray : Theme.accent

        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    /// Keep dragged rows inside their own category.
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard sourceIndexPath.section == proposedDestinationIndexPath.section else {
            let lastRow = max(store.sections[sourceIndexPath.section].count - 1, 0)
            let row = proposedDestinationIndexPath.section < sourceIndexPath.section ? 0 : lastRow
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    /// Touch and hold: change the quantity.
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let item = store.item(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let more = UIAction(title: "One More (\(item.quantity + 1))", image: UIImage(systemName: "plus.circle")) { _ in
                self?.changeQuantity(at: indexPath, by: 1)
            }
            let fewer = UIAction(title: "One Fewer",
                                 image: UIImage(systemName: "minus.circle"),
                                 attributes: item.quantity > 1 ? [] : [.disabled]) { _ in
                self?.changeQuantity(at: indexPath, by: -1)
            }
            return UIMenu(title: item.title, children: [more, fewer])
        }
    }
}
