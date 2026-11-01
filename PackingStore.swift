import Foundation

extension Notification.Name {
    static let packingStoreDidChange = Notification.Name("packingStoreDidChange")
}

/// In-memory source of truth for the packing list. `sections` lines up with
/// `PackingCategory.allCases`, so a table view section index maps straight to a category.
final class PackingStore {

    static let shared = PackingStore()

    private(set) var sections: [[PackingItem]]

    private init() {
        sections = Array(repeating: [PackingItem](), count: PackingCategory.allCases.count)
        seed()
    }

    // MARK: Queries

    func item(at indexPath: IndexPath) -> PackingItem {
        return sections[indexPath.section][indexPath.row]
    }

    var totalCount: Int {
        return sections.joined().count
    }

    var packedCount: Int {
        return sections.joined().filter { $0.isPacked }.count
    }

    // MARK: Mutations

    func toggle(at indexPath: IndexPath) {
        sections[indexPath.section][indexPath.row].isPacked.toggle()
        changed()
    }

    func remove(at indexPath: IndexPath) {
        sections[indexPath.section].remove(at: indexPath.row)
        changed()
    }

    /// Reordering is limited to a single category.
    func move(from source: IndexPath, to destination: IndexPath) {
        guard source.section == destination.section else { return }
        let item = sections[source.section].remove(at: source.row)
        sections[destination.section].insert(item, at: destination.row)
        changed()
    }

    @discardableResult
    func add(_ item: PackingItem) -> IndexPath {
        let section = item.category.index
        sections[section].append(item)
        changed()
        return IndexPath(row: sections[section].count - 1, section: section)
    }

    func adjustQuantity(at indexPath: IndexPath, by delta: Int) {
        let current = sections[indexPath.section][indexPath.row].quantity
        sections[indexPath.section][indexPath.row].quantity = min(99, max(1, current + delta))
        changed()
    }

    func setNote(_ note: String, at indexPath: IndexPath) {
        sections[indexPath.section][indexPath.row].note = note
        changed()
    }

    /// Adds the suggested items for a climate, skipping anything already on the list.
    /// Returns how many items were actually added.
    @discardableResult
    func addSuggestions(for climate: Climate) -> Int {
        var knownTitles = Set(sections.joined().map { $0.title.lowercased() })
        var added = 0
        for suggestion in climate.suggestedItems where !knownTitles.contains(suggestion.title.lowercased()) {
            let item = PackingItem(title: suggestion.title,
                                   category: suggestion.category,
                                   quantity: suggestion.quantity,
                                   isPacked: false,
                                   note: suggestion.note)
            sections[suggestion.category.index].append(item)
            knownTitles.insert(suggestion.title.lowercased())
            added += 1
        }
        if added > 0 { changed() }
        return added
    }

    func unpackAll() {
        for section in sections.indices {
            for row in sections[section].indices {
                sections[section][row].isPacked = false
            }
        }
        changed()
    }

    func removePacked() {
        for section in sections.indices {
            sections[section].removeAll { $0.isPacked }
        }
        changed()
    }

    // MARK: Private

    private func changed() {
        NotificationCenter.default.post(name: .packingStoreDidChange, object: nil)
    }

    private func seed() {
        let starter: [PackingItem] = [
            PackingItem(title: "Passport", category: .documents, quantity: 1, isPacked: true, note: "Check the expiry date"),
            PackingItem(title: "Travel insurance", category: .documents, quantity: 1, isPacked: false, note: ""),
            PackingItem(title: "Boarding passes", category: .documents, quantity: 1, isPacked: false, note: "Download for offline use"),
            PackingItem(title: "Hotel confirmations", category: .documents, quantity: 1, isPacked: false, note: ""),

            PackingItem(title: "T-shirts", category: .clothing, quantity: 4, isPacked: false, note: ""),
            PackingItem(title: "Jeans", category: .clothing, quantity: 2, isPacked: false, note: ""),
            PackingItem(title: "Comfortable sneakers", category: .clothing, quantity: 1, isPacked: false, note: "Break them in first"),
            PackingItem(title: "Rain jacket", category: .clothing, quantity: 1, isPacked: false, note: ""),

            PackingItem(title: "Phone charger", category: .electronics, quantity: 1, isPacked: true, note: ""),
            PackingItem(title: "Power adapter", category: .electronics, quantity: 1, isPacked: false, note: "Check the plug type"),
            PackingItem(title: "Camera", category: .electronics, quantity: 1, isPacked: false, note: "Charge the battery"),
            PackingItem(title: "Headphones", category: .electronics, quantity: 1, isPacked: false, note: ""),

            PackingItem(title: "Toothbrush", category: .toiletries, quantity: 1, isPacked: true, note: ""),
            PackingItem(title: "Sunscreen", category: .toiletries, quantity: 1, isPacked: false, note: "SPF 50"),
            PackingItem(title: "Travel-size shampoo", category: .toiletries, quantity: 1, isPacked: false, note: ""),

            PackingItem(title: "Reusable water bottle", category: .extras, quantity: 1, isPacked: false, note: ""),
            PackingItem(title: "Notebook & pen", category: .extras, quantity: 1, isPacked: false, note: ""),
            PackingItem(title: "Snacks", category: .extras, quantity: 3, isPacked: false, note: "For the long flight")
        ]
        for item in starter {
            sections[item.category.index].append(item)
        }
    }
}
