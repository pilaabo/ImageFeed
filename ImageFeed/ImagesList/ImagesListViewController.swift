import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView?
    
    // MARK: - Properties

    private let photosNames = Array(0..<20).map { "\($0)" }
    
    // MARK: - Date Formatter
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosNames[indexPath.row]) else {
            return
        }
        
        cell.setImage(image)
        cell.setDate(Date())
        
        let likeImage = indexPath.row % 2 == 0
            ? UIImage(named: "Liked")
            : UIImage(named: "Not Liked")
        
        cell.setLike(likeImage)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Показывать картинку во весь экран по нажатию на ячейку
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosNames[indexPath.row]) else {
            return 0
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let tableWidth = tableView.bounds.width
        
        guard imageWidth > 0 else {
            return 0
        }
        
        let scaledHeight = imageHeight * (tableWidth / imageWidth)
        
        return scaledHeight
    }
}
