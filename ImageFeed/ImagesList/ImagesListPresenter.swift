import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties

    weak var view: ImagesListViewControllerProtocol?

    private(set) var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?

    // MARK: - ImagesListPresenterProtocol

    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            let oldCount = self.photos.count
            self.photos = ImagesListService.shared.photos
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: self.photos.count)
        }

        ImagesListService.shared.fetchPhotosNextPage()
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }

    func willDisplayRow(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }

    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        view?.setLoading(true)
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            self.view?.setLoading(false)

            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                self.view?.reloadRow(at: indexPath)
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
}

// MARK: - ImagesListViewControllerProtocol

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadRow(at indexPath: IndexPath)
    func setLoading(_ isLoading: Bool)
    func showLikeError()
}

// MARK: - ImagesListPresenterProtocol

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }

    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func willDisplayRow(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}
