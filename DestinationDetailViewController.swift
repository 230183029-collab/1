import UIKit

/// Detail screen pushed from the collection view.
final class DestinationDetailViewController: UIViewController {

    private let destination: Destination

    init(destination: Destination) {
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = destination.name
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleFavorite))
        updateFavoriteButton()
        buildContent()
    }

    // MARK: UI

    private func buildContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        let hero = makeHero()
        hero.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(hero)

        let stats = UIStackView(arrangedSubviews: [
            makeStatCard(symbol: "calendar", value: destination.bestSeason, caption: "Best season"),
            makeStatCard(symbol: "dollarsign.circle.fill", value: "$\(destination.budgetPerDay)", caption: "Per day"),
            makeStatCard(symbol: destination.climate.symbol, value: destination.climate.rawValue, caption: "Climate")
        ])
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.spacing = 12

        let aboutTitle = UILabel()
        aboutTitle.text = "About"
        aboutTitle.font = .systemFont(ofSize: 20, weight: .bold)

        let aboutBody = UILabel()
        aboutBody.text = destination.blurb
        aboutBody.font = .preferredFont(forTextStyle: .body)
        aboutBody.textColor = .secondaryLabel
        aboutBody.numberOfLines = 0

        let about = UIStackView(arrangedSubviews: [aboutTitle, aboutBody])
        about.axis = .vertical
        about.spacing = 8

        var config = UIButton.Configuration.filled()
        config.title = "Add Packing List"
        config.image = UIImage(systemName: "suitcase.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = Theme.accent
        config.cornerStyle = .large
        let packButton = UIButton(configuration: config)
        packButton.addTarget(self, action: #selector(addPackingList), for: .touchUpInside)

        let infoStack = UIStackView(arrangedSubviews: [stats, about, packButton])
        infoStack.axis = .vertical
        infoStack.spacing = 22
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(infoStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            hero.topAnchor.constraint(equalTo: content.topAnchor),
            hero.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            hero.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            hero.heightAnchor.constraint(equalToConstant: 250),

            infoStack.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 22),
            infoStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            infoStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -32),

            packButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func makeHero() -> UIView {
        let hero = GradientView()
        hero.setColors(destination.gradient)

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 88, weight: .semibold)
        let symbolView = UIImageView(image: UIImage(systemName: destination.symbol, withConfiguration: symbolConfig))
        symbolView.tintColor = UIColor.white.withAlphaComponent(0.9)
        symbolView.contentMode = .scaleAspectFit
        symbolView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = destination.name
        nameLabel.font = .systemFont(ofSize: 34, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6

        let countryLabel = UILabel()
        countryLabel.text = "\(destination.country) · \(destination.region.rawValue)"
        countryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countryLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        let labels = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        labels.axis = .vertical
        labels.spacing = 2
        labels.translatesAutoresizingMaskIntoConstraints = false

        hero.addSubview(symbolView)
        hero.addSubview(labels)

        NSLayoutConstraint.activate([
            symbolView.centerXAnchor.constraint(equalTo: hero.centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: hero.centerYAnchor, constant: -20),
            symbolView.widthAnchor.constraint(equalToConstant: 120),
            symbolView.heightAnchor.constraint(equalToConstant: 120),

            labels.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            labels.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            labels.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -20)
        ])
        return hero
    }

    private func makeStatCard(symbol: String, value: String, caption: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = destination.gradient.first ?? Theme.accent
        icon.contentMode = .scaleAspectFit

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .preferredFont(forTextStyle: .caption1)
        captionLabel.textColor = .secondaryLabel
        captionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [icon, valueLabel, captionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            icon.heightAnchor.constraint(equalToConstant: 24)
        ])
        return card
    }

    private func updateFavoriteButton() {
        let name = destination.isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: name)
        navigationItem.rightBarButtonItem?.tintColor = destination.isFavorite ? .systemRed : Theme.accent
        navigationItem.rightBarButtonItem?.accessibilityLabel = destination.isFavorite ? "Remove from favorites" : "Add to favorites"
    }

    // MARK: Actions

    @objc private func toggleFavorite() {
        destination.isFavorite.toggle()
        updateFavoriteButton()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @objc private func addPackingList() {
        let added = PackingStore.shared.addSuggestions(for: destination.climate)
        UINotificationFeedbackGenerator().notificationOccurred(added > 0 ? .success : .warning)

        if added > 0 {
            showToast("Added \(added) item\(added == 1 ? "" : "s") for \(destination.name)")
        } else {
            showToast("Those items are already on your list")
        }
    }
}
