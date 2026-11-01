import UIKit

/// Table view cell: check circle, title (struck through when packed), optional note and quantity pill.
final class PackingItemCell: UITableViewCell {

    static let reuseID = "PackingItemCell"

    private let checkView = UIImageView()
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let quantityLabel = PaddedLabel()

    private let titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        checkView.contentMode = .scaleAspectFit
        checkView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        checkView.translatesAutoresizingMaskIntoConstraints = false

        noteLabel.font = .preferredFont(forTextStyle: .footnote)
        noteLabel.textColor = .secondaryLabel

        quantityLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        quantityLabel.textColor = .secondaryLabel
        quantityLabel.backgroundColor = .tertiarySystemFill
        quantityLabel.layer.cornerRadius = 11
        quantityLabel.clipsToBounds = true
        quantityLabel.insets = UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 9)
        quantityLabel.setContentHuggingPriority(.required, for: .horizontal)
        quantityLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, noteLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(checkView)
        contentView.addSubview(textStack)
        contentView.addSubview(quantityLabel)

        NSLayoutConstraint.activate([
            checkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkView.widthAnchor.constraint(equalToConstant: 28),
            checkView.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: checkView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: quantityLabel.leadingAnchor, constant: -8),

            quantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: PackingItem) {
        let packed = item.isPacked

        checkView.image = UIImage(systemName: packed ? "checkmark.circle.fill" : "circle")
        checkView.tintColor = packed ? Theme.accent : .tertiaryLabel

        var attributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        if packed {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            attributes[.foregroundColor] = UIColor.secondaryLabel
        } else {
            attributes[.foregroundColor] = UIColor.label
        }
        titleLabel.attributedText = NSAttributedString(string: item.title, attributes: attributes)

        noteLabel.text = item.note
        noteLabel.isHidden = item.note.isEmpty

        quantityLabel.text = "×\(item.quantity)"
        quantityLabel.isHidden = item.quantity <= 1
    }
}
