import Foundation
import Logging

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private init() {
    }

    private let logger = Logger(label: "ImagesListService")

    private var task: URLSessionTask?

    private(set) var photos: [Photo] = []

    private var lastLoadedPage = 0

    private func makeImagesListRequest(token: String) -> URLRequest? {
        let urlString = Constants.defaultBaseURLString + "/photos"

        guard var urlComponents = URLComponents(string: urlString) else {
            logger.error("makeImagesListRequest: failed to create URLComponents from '\(urlString)'")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(lastLoadedPage + 1)"),
            URLQueryItem(name: "per_page", value: "\(Constants.photosPerPage)")
        ]

        guard let url = urlComponents.url else {
            logger.error("makeImagesListRequest: failed to build URL from URLComponents: \(urlComponents)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeChangeLikeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
        let urlString = Constants.defaultBaseURLString + "/photos/\(photoId)/like"

        guard let url = URL(string: urlString) else {
            logger.error("makeChangeLikeRequest: failed to build URL from '\(urlString)'")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard task == nil else { return }

        guard let token = OAuth2TokenStorage.token else {
            logger.error("fetchPhotosNextPage: NetworkError.invalidRequest - missing OAuth token")
            return
        }

        guard let request = makeImagesListRequest(token: token) else {
            logger.error("fetchPhotosNextPage: NetworkError.invalidRequest - unable to build URLRequest")
            return
        }

        var task: URLSessionTask?
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            switch result {
            case .success(let responseBody):
                let newPhotos = responseBody.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: photoResult.createdAt,
                        description: photoResult.description,
                        regularImageURL: photoResult.urls.regularUrl,
                        largeImageURL: photoResult.urls.fullUrl,
                        isLiked: photoResult.likedByUser
                    )
                }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage += 1

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: nil
                )
            case .failure(let error):
                self.logger.error("fetchPhotosNextPage failed: \(error.localizedDescription)")
            }

            if self.task === task { self.task = nil }
        }
        self.task = task
        task?.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard let token = OAuth2TokenStorage.token else {
            logger.error("changeLike: NetworkError.invalidRequest - missing OAuth token")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        guard let request = makeChangeLikeRequest(token: token, photoId: photoId, isLike: isLike) else {
            logger.error("changeLike: NetworkError.invalidRequest - unable to build URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        URLSession.shared.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self else { return }

            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index] = self.photos[index].withIsLiked(isLike)
                }
                completion(.success(()))
            case .failure(let error):
                self.logger.error("changeLike failed with photoId = \(photoId): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    func resetFetchedPhotos() {
        task?.cancel()
        task = nil
        photos = []
        lastLoadedPage = 0
    }
}
