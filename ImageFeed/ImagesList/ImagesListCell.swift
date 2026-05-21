import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - Reuse Identifier

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - Outlets

    @IBOutlet private weak var cellImage: UIImageView?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var likeButton: UIButton?
    @IBOutlet private weak var gradientView: UIView?

    // MARK: - Actions

    @IBAction private func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }

    // MARK: - Properties

    weak var delegate: ImagesListCellDelegate?

    private let gradientLayer = CAGradientLayer()

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage?.kf.cancelDownloadTask()
        cellImage?.image = UIImage(resource: .imagesListStub)
        dateLabel?.text = nil
    }
    
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

    func setImage(_ url: URL) {
        cellImage?.kf.indicatorType = .activity
        cellImage?.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .imagesListStub),
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        )
    }

    func setDate(_ date: Date?) {
        dateLabel?.text = date.map { ImagesListCell.dateFormatter.string(from: $0) }
    }

    func setIsLiked(_ isLiked: Bool) {
        let likeImage = UIImage(resource: isLiked ? .likedButton : .notLikedButton)
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

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}
