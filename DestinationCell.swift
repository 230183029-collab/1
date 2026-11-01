import UIKit

/// Collection view cell: gradient card with a big SF Symbol, name, country and a price pill.
final class DestinationCell: UICollectionViewCell {

    static let reuseID = "DestinationCell"

    private let cornerRadius: CGFloat = 20
    private let gradientView = GradientView()
    private let symbolView = UIImageView()
    private let heartView = UIImageView()
    private let nameLabel = UILabel()
    private let countryLabel = UILabel()
    private let priceLabel = PaddedLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        // The shadow lives on the cell layer, the rounded clipping on the content view.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 5)

        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)

        symbolView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 52, weight: .semibold)
        symbolView.tintColor = UIColor.white.withAlphaComponent(0.4)
        symbolView.contentMode = .scaleAspectFit
        symbolView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(symbolView)

        heartView.image = UIImage(systemName: "heart.fill")
        heartView.tintColor = .white
        heartView.contentMode = .scaleAspectFit
        heartView.layer.shadowColor = UIColor.black.cgColor
        heartView.layer.shadowOpacity = 0.35
        heartView.layer.shadowRadius = 3
        heartView.layer.shadowOffset = .zero
        heartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heartView)

        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7

        countryLabel.font = .systemFont(ofSize: 14, weight: .medium)
        countryLabel.textColor = UIColor.white.withAlphaComponent(0.88)

        priceLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        priceLabel.textColor = .white
        priceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        priceLabel.layer.cornerRadius = 10
        priceLabel.clipsToBounds = true
        priceLabel.insets = UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 9)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, countryLabel, priceLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2
        textStack.setCustomSpacing(8, after: countryLabel)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            symbolView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            symbolView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            symbolView.widthAnchor.constraint(equalToConstant: 72),
            symbolView.heightAnchor.constraint(equalToConstant: 72),

            heartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            heartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            heartView.widthAnchor.constraint(equalToConstant: 22),
            heartView.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        transform = .identity
        alpha = 1
    }

    func configure(with destination: Destination) {
        gradientView.setColors(destination.gradient)
        symbolView.image = UIImage(systemName: destination.symbol)
        nameLabel.text = destination.name
        countryLabel.text = destination.country
        priceLabel.text = "~$\(destination.budgetPerDay) / day"
        heartView.isHidden = !destination.isFavorite
    }

    /// Press feedback driven by the collection view's highlight callbacks.
    func setPressed(_ pressed: Bool) {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = pressed ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        }
    }
}
