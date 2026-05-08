import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Reuse Identifier

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - Outlets

    @IBOutlet private weak var cellImage: UIImageView?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var likeButton: UIButton?
    @IBOutlet private weak var gradientView: UIView?

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientView else {
            return
        }
        gradientLayer.frame = gradientView.bounds
    }

    // MARK: - Public Configuration Methods

    func setImage(_ image: UIImage?) {
        guard let image else {
            return
        }
        cellImage?.image = image
    }

    func setDate(_ date: Date) {
        dateLabel?.text = ImagesListCell.dateFormatter.string(from: date)
    }

    func setLike(_ likeImage: UIImage?) {
        guard let likeImage else {
            return
        }
        likeButton?.setImage(likeImage, for: .normal)
    }

    // MARK: - Private Methods

    private func setupGradient() {
        gradientLayer.colors = [UIColor.backgroundTransparent.cgColor, UIColor.background.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        gradientView?.layer.insertSublayer(gradientLayer, at: 0)
    }
}
