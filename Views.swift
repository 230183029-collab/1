import UIKit

// MARK: - Theme

enum Theme {
    static let accent = UIColor(hex: 0x0B8494)
    static let background = UIColor.systemGroupedBackground
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

// MARK: - Reusable small views

/// A label that draws its text inset from its edges, used for pill-shaped badges.
final class PaddedLabel: UILabel {

    var insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10) {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

/// A view backed by a CAGradientLayer so the gradient resizes with Auto Layout.
final class GradientView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    func setColors(_ colors: [UIColor]) {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
}

/// Section header for the destinations collection view.
final class RegionHeaderView: UICollectionReusableView {

    static let reuseID = "RegionHeaderView"

    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        countLabel.font = .preferredFont(forTextStyle: .subheadline)
        countLabel.textColor = .secondaryLabel

        [titleLabel, countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            countLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = count == 1 ? "1 place" : "\(count) places"
    }
}

/// Section header for the packing list table view: icon, category name and item count.
final class CategoryHeaderView: UITableViewHeaderFooterView {

    static let reuseID = "CategoryHeaderView"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        iconView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        countLabel.font = .preferredFont(forTextStyle: .subheadline)
        countLabel.textColor = .secondaryLabel

        [iconView, titleLabel, countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            countLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(category: PackingCategory, count: Int) {
        iconView.image = UIImage(systemName: category.symbol)
        iconView.tintColor = category.color
        titleLabel.text = category.rawValue
        countLabel.text = count == 1 ? "1 item" : "\(count) items"
    }
}

// MARK: - Toast

extension UIViewController {

    /// Shows a short, self-dismissing message near the bottom of the screen.
    func showToast(_ message: String) {
        let label = PaddedLabel()
        label.insets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        label.text = message
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.82)
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])

        UIView.animate(withDuration: 0.25, animations: {
            label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.6, options: [], animations: {
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        })
    }
}
