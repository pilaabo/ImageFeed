import UIKit
import Logging

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView?

    // MARK: - Private Properties

    private static let showSingleImageSegueId = "ShowSingleImage"

    private var imagesListServiceObserver: NSObjectProtocol?

    private var images: [Image] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let oldCount = self.images.count
            self.images = ImagesListService.shared.images
            self.updateTableViewAnimated(oldCount: oldCount, newCount: self.images.count)
        }
        
        ImagesListService.shared.fetchImagesNextPage()
    }
    
    // MARK: - Private Methods
    
    private func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard let tableView, newCount > oldCount else { return }

        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.showSingleImageSegueId,
           let singleImageVC = segue.destination as? SingleImageViewController,
           let cell = sender as? ImagesListCell {

            guard let indexPath = tableView?.indexPath(for: cell) else { return }
            let image = images[indexPath.row]
            singleImageVC.imageUrl = image.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = images[indexPath.row]
        cell.setImage(image.regularImageURL)
        cell.setDate(image.createdAt)
        
        let likeImage = image.isLiked
        ? UIImage(resource: .likedButton)
        : UIImage(resource: .notLikedButton)
        
        cell.setLike(likeImage)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == images.count - 1 {
            ImagesListService.shared.fetchImagesNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = images[indexPath.row]

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

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        let image = images[indexPath.row]
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(imageId: image.id, isLike: !image.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success:
                self.images = ImagesListService.shared.images
                self.tableView?.reloadRows(at: [indexPath], with: .none)
            case .failure:
                self.showErrorAlert(message: "Не удалось обновить лайк")
            }
        }
    }
}
