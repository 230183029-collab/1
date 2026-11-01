import UIKit

// MARK: - Destinations

enum Region: String, CaseIterable {
    case asia = "Asia"
    case europe = "Europe"
    case americas = "The Americas"
    case africaOceania = "Africa & Oceania"

    var emoji: String {
        switch self {
        case .asia: return "🏯"
        case .europe: return "🏰"
        case .americas: return "🗽"
        case .africaOceania: return "🦁"
        }
    }
}

enum Climate: String {
    case tropical = "Tropical"
    case temperate = "Temperate"
    case cold = "Cold"
    case desert = "Desert"

    var symbol: String {
        switch self {
        case .tropical: return "sun.max.fill"
        case .temperate: return "cloud.sun.fill"
        case .cold: return "snowflake"
        case .desert: return "sun.dust.fill"
        }
    }
}

final class Destination {
    let id = UUID()
    let name: String
    let country: String
    let region: Region
    let climate: Climate
    let symbol: String
    let gradient: [UIColor]
    let blurb: String
    let bestSeason: String
    let budgetPerDay: Int
    var isFavorite: Bool

    init(name: String,
         country: String,
         region: Region,
         climate: Climate,
         symbol: String,
         gradient: [UIColor],
         blurb: String,
         bestSeason: String,
         budgetPerDay: Int,
         isFavorite: Bool = false) {
        self.name = name
        self.country = country
        self.region = region
        self.climate = climate
        self.symbol = symbol
        self.gradient = gradient
        self.blurb = blurb
        self.bestSeason = bestSeason
        self.budgetPerDay = budgetPerDay
        self.isFavorite = isFavorite
    }
}

enum DestinationCatalog {
    static let all: [Destination] = [
        // Asia
        Destination(name: "Kyoto", country: "Japan", region: .asia, climate: .temperate,
                    symbol: "leaf.fill",
                    gradient: [UIColor(hex: 0xFF9966), UIColor(hex: 0xFF5E62)],
                    blurb: "Temples, tea houses and lantern-lit lanes. Autumn maples and spring cherry blossoms turn the old capital into a painting.",
                    bestSeason: "Mar–May", budgetPerDay: 140, isFavorite: true),
        Destination(name: "Bali", country: "Indonesia", region: .asia, climate: .tropical,
                    symbol: "water.waves",
                    gradient: [UIColor(hex: 0x11998E), UIColor(hex: 0x2BC48A)],
                    blurb: "Rice terraces, surf breaks and sunrise hikes up volcanoes. Easy to spend a week and still want more.",
                    bestSeason: "Apr–Oct", budgetPerDay: 70),
        Destination(name: "Hanoi", country: "Vietnam", region: .asia, climate: .tropical,
                    symbol: "cup.and.saucer.fill",
                    gradient: [UIColor(hex: 0xC33764), UIColor(hex: 0x6A3093)],
                    blurb: "Egg coffee, noodle soup on plastic stools and motorbikes everywhere. The Old Quarter rewards wandering.",
                    bestSeason: "Oct–Apr", budgetPerDay: 50),

        // Europe
        Destination(name: "Santorini", country: "Greece", region: .europe, climate: .temperate,
                    symbol: "sun.max.fill",
                    gradient: [UIColor(hex: 0x2193B0), UIColor(hex: 0x4B8BD6)],
                    blurb: "White-washed villages perched on a volcanic caldera. Come for the sunsets, stay for the grilled octopus.",
                    bestSeason: "May–Sep", budgetPerDay: 180),
        Destination(name: "Reykjavik", country: "Iceland", region: .europe, climate: .cold,
                    symbol: "snowflake",
                    gradient: [UIColor(hex: 0x4568DC), UIColor(hex: 0xB06AB3)],
                    blurb: "A small capital and the doorway to glaciers, geysers and the northern lights.",
                    bestSeason: "Sep–Mar", budgetPerDay: 210, isFavorite: true),
        Destination(name: "Lisbon", country: "Portugal", region: .europe, climate: .temperate,
                    symbol: "tram.fill",
                    gradient: [UIColor(hex: 0xF7971E), UIColor(hex: 0xE8590C)],
                    blurb: "Steep hills, yellow trams and custard tarts. A relaxed, sunny capital with great value.",
                    bestSeason: "Apr–Oct", budgetPerDay: 100),

        // The Americas
        Destination(name: "Banff", country: "Canada", region: .americas, climate: .cold,
                    symbol: "mountain.2.fill",
                    gradient: [UIColor(hex: 0x136A8A), UIColor(hex: 0x267871)],
                    blurb: "Turquoise lakes under jagged Rocky Mountain peaks. Hike in summer, ski in winter.",
                    bestSeason: "Jun–Sep", budgetPerDay: 160),
        Destination(name: "Cusco", country: "Peru", region: .americas, climate: .temperate,
                    symbol: "tree.fill",
                    gradient: [UIColor(hex: 0x642B73), UIColor(hex: 0xC6426E)],
                    blurb: "The gateway to Machu Picchu and the Sacred Valley. Take a couple of days to adjust to the altitude.",
                    bestSeason: "May–Sep", budgetPerDay: 80),
        Destination(name: "New York City", country: "USA", region: .americas, climate: .temperate,
                    symbol: "building.2.fill",
                    gradient: [UIColor(hex: 0x232526), UIColor(hex: 0x4A4F52)],
                    blurb: "Five boroughs of museums, music and food from everywhere. Walk a lot, ride the subway, never sleep.",
                    bestSeason: "Sep–Nov", budgetPerDay: 250),

        // Africa & Oceania
        Destination(name: "Marrakech", country: "Morocco", region: .africaOceania, climate: .desert,
                    symbol: "sun.dust.fill",
                    gradient: [UIColor(hex: 0xD38312), UIColor(hex: 0xA83279)],
                    blurb: "Spice-scented souks, riad courtyards and the Atlas Mountains on the horizon.",
                    bestSeason: "Mar–May", budgetPerDay: 90),
        Destination(name: "Cape Town", country: "South Africa", region: .africaOceania, climate: .temperate,
                    symbol: "wind",
                    gradient: [UIColor(hex: 0x3A7BD5), UIColor(hex: 0x00A8CC)],
                    blurb: "Table Mountain, penguins on the beach and some of the world's best wine only an hour away.",
                    bestSeason: "Nov–Mar", budgetPerDay: 95),
        Destination(name: "Queenstown", country: "New Zealand", region: .africaOceania, climate: .cold,
                    symbol: "bolt.fill",
                    gradient: [UIColor(hex: 0x0F2027), UIColor(hex: 0x2C5364)],
                    blurb: "The adventure capital: bungee, jet boats and alpine lakes framed by the Remarkables.",
                    bestSeason: "Dec–Feb", budgetPerDay: 170)
    ]
}

// MARK: - Packing

enum PackingCategory: String, CaseIterable {
    case documents = "Documents"
    case clothing = "Clothing"
    case electronics = "Electronics"
    case toiletries = "Toiletries"
    case extras = "Extras"

    var symbol: String {
        switch self {
        case .documents: return "doc.text.fill"
        case .clothing: return "tshirt.fill"
        case .electronics: return "bolt.fill"
        case .toiletries: return "drop.fill"
        case .extras: return "star.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .documents: return .systemIndigo
        case .clothing: return .systemPink
        case .electronics: return .systemOrange
        case .toiletries: return .systemTeal
        case .extras: return .systemPurple
        }
    }

    /// Position of the category, which doubles as the table view section index.
    var index: Int {
        return PackingCategory.allCases.firstIndex(of: self) ?? 0
    }
}

struct PackingItem {
    let id = UUID()
    var title: String
    var category: PackingCategory
    var quantity: Int
    var isPacked: Bool
    var note: String
}

struct PackingSuggestion {
    let title: String
    let category: PackingCategory
    let quantity: Int
    let note: String
}

extension Climate {
    /// Items worth packing for a climate, plus a few essentials for every trip.
    var suggestedItems: [PackingSuggestion] {
        let essentials = [
            PackingSuggestion(title: "Passport", category: .documents, quantity: 1, note: "Check the expiry date"),
            PackingSuggestion(title: "Phone charger", category: .electronics, quantity: 1, note: ""),
            PackingSuggestion(title: "Toothbrush", category: .toiletries, quantity: 1, note: "")
        ]

        let specific: [PackingSuggestion]
        switch self {
        case .tropical:
            specific = [
                PackingSuggestion(title: "Swimsuit", category: .clothing, quantity: 2, note: ""),
                PackingSuggestion(title: "Light linen shirts", category: .clothing, quantity: 4, note: "Breathable fabrics"),
                PackingSuggestion(title: "Insect repellent", category: .toiletries, quantity: 1, note: ""),
                PackingSuggestion(title: "Waterproof phone pouch", category: .electronics, quantity: 1, note: "")
            ]
        case .temperate:
            specific = [
                PackingSuggestion(title: "Light jacket", category: .clothing, quantity: 1, note: "Evenings can be cool"),
                PackingSuggestion(title: "Compact umbrella", category: .extras, quantity: 1, note: ""),
                PackingSuggestion(title: "Walking shoes", category: .clothing, quantity: 1, note: "Lots of steps ahead"),
                PackingSuggestion(title: "Power adapter", category: .electronics, quantity: 1, note: "Check the plug type")
            ]
        case .cold:
            specific = [
                PackingSuggestion(title: "Thermal base layers", category: .clothing, quantity: 3, note: ""),
                PackingSuggestion(title: "Insulated jacket", category: .clothing, quantity: 1, note: ""),
                PackingSuggestion(title: "Wool hat & gloves", category: .clothing, quantity: 1, note: ""),
                PackingSuggestion(title: "Lip balm", category: .toiletries, quantity: 1, note: "Cold wind dries lips"),
                PackingSuggestion(title: "Portable charger", category: .electronics, quantity: 1, note: "Batteries drain faster in the cold")
            ]
        case .desert:
            specific = [
                PackingSuggestion(title: "Wide-brim hat", category: .clothing, quantity: 1, note: ""),
                PackingSuggestion(title: "Sunglasses", category: .extras, quantity: 1, note: ""),
                PackingSuggestion(title: "Light scarf", category: .clothing, quantity: 1, note: "Sun and dust protection"),
                PackingSuggestion(title: "Sunscreen", category: .toiletries, quantity: 1, note: "SPF 50"),
                PackingSuggestion(title: "Electrolyte sachets", category: .extras, quantity: 6, note: "")
            ]
        }
        return specific + essentials
    }
}
