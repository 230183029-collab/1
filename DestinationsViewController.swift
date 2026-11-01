import UIKit

/// "Explore" tab: destinations grouped by region in a UICollectionView.
final class DestinationsViewController: UIViewController {

    // MARK: Layout constants

    private enum Metrics {
        static let sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
        static let itemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 14
        static let featuredHeight: CGFloat = 210
        static let compactHeight: CGFloat = 190
        static let headerHeight: CGFloat = 48
    }

    // MARK: State

    private let allDestinations = DestinationCatalog.all
    private var sections: [(region: Region, items: [Destination])] = []
    /// Destinations whose cells have already played their entrance animation.
    private var revealedIDs = Set<UUID>()

    // MARK: Views

    private let filterControl = UISegmentedControl(items: ["All", "Favorites"])

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet.\nTouch and hold a destination to add one."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never

        configureNavigationItem()
        configureCollectionView()
        rebuildSections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // A favorite may have been toggled on the detail screen.
        rebuildSections()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: Setup

    private func configureNavigationItem() {
        filterControl.selectedSegmentIndex = 0
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        navigationItem.titleView = filterControl

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(surpriseMe))
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Surprise me"
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DestinationCell.self,
                                forCellWithReuseIdentifier: DestinationCell.reuseID)
        collectionView.register(RegionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RegionHeaderView.reuseID)

        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: Data

    private func rebuildSections() {
        let favoritesOnly = filterControl.selectedSegmentIndex == 1
        sections = Region.allCases.compactMap { region -> (region: Region, items: [Destination])? in
            let items = allDestinations.filter { $0.region == region && (!favoritesOnly || $0.isFavorite) }
            return items.isEmpty ? nil : (region: region, items: items)
        }
        collectionView.reloadData()
        emptyLabel.isHidden = !sections.isEmpty
    }

    private func destination(at indexPath: IndexPath) -> Destination {
        return sections[indexPath.section].items[indexPath.item]
    }

    // MARK: Actions

    @objc private func filterChanged() {
        rebuildSections()
        let top = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
        collectionView.setContentOffset(top, animated: false)
    }

    @objc private func surpriseMe() {
        guard let pick = allDestinations.randomElement() else { return }
        navigationController?.pushViewController(DestinationDetailViewController(destination: pick), animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension DestinationsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DestinationCell.reuseID,
                                                            for: indexPath) as? DestinationCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: destination(at: indexPath))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: RegionHeaderView.reuseID,
                                                                           for: indexPath) as? RegionHeaderView else {
            return UICollectionReusableView()
        }
        let section = sections[indexPath.section]
        header.configure(title: "\(section.region.emoji)  \(section.region.rawValue)", count: section.items.count)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension DestinationsViewController: UICollectionViewDelegate {

    /// Open the detail screen for the tapped destination.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let detail = DestinationDetailViewController(destination: destination(at: indexPath))
        navigationController?.pushViewController(detail, animated: true)
    }

    /// Shrink the card slightly while a finger is down.
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? DestinationCell)?.setPressed(true)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? DestinationCell)?.setPressed(false)
    }

    /// Fade and slide each card in the first time it appears.
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let id = destination(at: indexPath).id
        guard !revealedIDs.contains(id) else { return }
        revealedIDs.insert(id)

        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(withDuration: 0.45,
                       delay: Double(indexPath.item) * 0.05,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0,
                       options: [.allowUserInteraction]) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    /// Touch and hold: favorite a destination or drop its packing suggestions into the list.
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let destination = self.destination(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let favoriteTitle = destination.isFavorite ? "Remove from Favorites" : "Add to Favorites"
            let favoriteImage = UIImage(systemName: destination.isFavorite ? "heart.slash" : "heart")
            let favorite = UIAction(title: favoriteTitle, image: favoriteImage) { _ in
                destination.isFavorite.toggle()
                self?.rebuildSections()
            }

            let pack = UIAction(title: "Add Packing List", image: UIImage(systemName: "suitcase")) { _ in
                let added = PackingStore.shared.addSuggestions(for: destination.climate)
                let message = added == 0
                    ? "Everything is already on your list"
                    : "Added \(added) item\(added == 1 ? "" : "s") for \(destination.name)"
                self?.showToast(message)
            }

            return UIMenu(title: destination.name, children: [favorite, pack])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DestinationsViewController: UICollectionViewDelegateFlowLayout {

    /// First card of each region is full width; the rest sit two per row.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = Metrics.sectionInset
        let available = max(collectionView.bounds.width - inset.left - inset.right, 0)

        if indexPath.item == 0 {
            return CGSize(width: available, height: Metrics.featuredHeight)
        }
        let width = floor((available - Metrics.itemSpacing) / 2)
        return CGSize(width: max(width, 0), height: Metrics.compactHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return Metrics.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metrics.lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Metrics.itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Metrics.headerHeight)
    }
}
