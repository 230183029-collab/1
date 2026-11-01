import UIKit

/// Root controller: "Explore" (UICollectionView) and "Packing" (UITableView) tabs.
final class MainTabBarController: UITabBarController {

    private let packingNavigation = UINavigationController(rootViewController: PackingListViewController())

    override func viewDidLoad() {
        super.viewDidLoad()

        let exploreNavigation = UINavigationController(rootViewController: DestinationsViewController())
        exploreNavigation.tabBarItem = UITabBarItem(title: "Explore",
                                                    image: UIImage(systemName: "globe.europe.africa.fill"),
                                                    tag: 0)
        packingNavigation.tabBarItem = UITabBarItem(title: "Packing",
                                                    image: UIImage(systemName: "suitcase.fill"),
                                                    tag: 1)

        [exploreNavigation, packingNavigation].forEach {
            $0.navigationBar.prefersLargeTitles = true
            $0.navigationBar.tintColor = Theme.accent
        }

        viewControllers = [exploreNavigation, packingNavigation]
        tabBar.tintColor = Theme.accent

        // Keep the badge on the Packing tab in sync with the shared store.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshBadge),
                                               name: .packingStoreDidChange,
                                               object: nil)
        refreshBadge()
    }

    @objc private func refreshBadge() {
        let store = PackingStore.shared
        let remaining = store.totalCount - store.packedCount
        packingNavigation.tabBarItem.badgeValue = remaining > 0 ? "\(remaining)" : nil
    }
}
