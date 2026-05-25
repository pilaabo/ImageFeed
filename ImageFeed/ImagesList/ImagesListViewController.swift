import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView?

    // MARK: - Properties

    private var presenter: ImagesListPresenterProtocol!

    // MARK: - Private Properties

    private static let showSingleImageSegueId = "ShowSingleImage"

    // MARK: - Configuration

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    // MARK: - ImagesListViewControllerProtocol

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard let tableView, newCount > oldCount else { return }

        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView?.reloadRows(at: [indexPath], with: .none)
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }

    func showLikeError() {
        showErrorAlert(message: "Не удалось обновить лайк")
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.showSingleImageSegueId,
           let singleImageVC = segue.destination as? SingleImageViewController,
           let cell = sender as? ImagesListCell,
           let indexPath = tableView?.indexPath(for: cell) {
            singleImageVC.imageUrl = presenter.photo(at: indexPath).largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath)
        cell.setImage(photo.regularImageURL)
        cell.setDate(photo.createdAt)
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photos.count
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
        presenter.willDisplayRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath)

        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        let tableWidth = tableView.bounds.width

        guard imageWidth > 0 else { return 0 }

        return imageHeight * (tableWidth / imageWidth)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath)
    }
}
