import UIKit
import Logging

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView?

    // MARK: - Private Properties

    private static let showSingleImageSegueId = "ShowSingleImage"

    private var imagesListServiceObserver: NSObjectProtocol?

    private var photos: [Photo] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }

            let oldCount = self.photos.count
            self.photos = ImagesListService.shared.photos
            self.updateTableViewAnimated(oldCount: oldCount, newCount: self.photos.count)
        }

        ImagesListService.shared.fetchPhotosNextPage()
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
            let photo = photos[indexPath.row]
            singleImageVC.imageUrl = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.setImage(photo.regularImageURL)
        cell.setDate(photo.createdAt)
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
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
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]

        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
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
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                self.tableView?.reloadRows(at: [indexPath], with: .none)
            case .failure:
                self.showErrorAlert(message: "Не удалось обновить лайк")
            }
        }
    }
}
