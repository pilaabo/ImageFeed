import UIKit

class ImagesListCell: UITableViewCell {
    
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Outlets
    
    @IBOutlet weak var cellImage: UIImageView?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet private weak var gradientView: UIView? // private, не используется извне
    
    // MARK: - Properties
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientView else { return }
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Private Methods
    
    private func setupGradient() {
        let transparent = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor
        let opaque = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor
        
        gradientLayer.colors = [transparent, opaque]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        gradientView?.layer.insertSublayer(gradientLayer, at: 0)
    }
}
