import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    private func setupGradient() {
        let transparent = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor
        let opaque = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor

        gradientLayer.colors = [
            transparent,
            opaque
        ]
        gradientLayer.locations = [0.0, 1.0]

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
