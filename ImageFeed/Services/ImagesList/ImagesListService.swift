import Foundation
import Logging

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private init() {
    }

    private let logger = Logger(label: "ImagesListService")

    private var task: URLSessionTask?

    private(set) var images: [Image] = []
        
    private var lastLoadedPage = 0
    private let imagesPerPage = 10
    
    private func makeImagesListRequest(token: String) -> URLRequest? {
        let urlString = Constants.defaultBaseURLString + "/photos"
        
        guard var urlComponents = URLComponents(string: urlString) else {
            logger.error("makeImagesListRequest: failed to create URLComponents from '\(urlString)'")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(lastLoadedPage + 1)"),
            URLQueryItem(name: "per_page", value: "\(Constants.imagesPerPage)")
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

    private func makeChangeLikeRequest(token: String, imageId: String, isLike: Bool) -> URLRequest? {
        let urlString = Constants.defaultBaseURLString + "/photos/\(imageId)/like"

        guard let url = URL(string: urlString) else {
            logger.error("makeChangeLikeRequest: failed to build URL from '\(urlString)'")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func fetchImagesNextPage() {
        assert(Thread.isMainThread)

        task?.cancel()

        guard let token = OAuth2TokenStorage.token else {
            logger.error("fetchImagesNextPage: NetworkError.invalidRequest - missing OAuth token")
            return
        }
        
        guard let request = makeImagesListRequest(token: token) else {
            logger.error("fetchImagesNextPage: NetworkError.invalidRequest - unable to build URLRequest")
            return
        }
        
        var task: URLSessionTask?
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[ImageResponseBody], Error>) in
            guard let self else { return }

            switch result {
            case .success(let responseBody):
                let newImages = responseBody.map { imageResponseBody in
                    Image(
                        id: imageResponseBody.id,
                        size: CGSize(width: imageResponseBody.width, height: imageResponseBody.height),
                        createdAt: imageResponseBody.createdAt,
                        description: imageResponseBody.description,
                        regularImageURL: imageResponseBody.urls.regular,
                        largeImageURL: imageResponseBody.urls.full,
                        isLiked: imageResponseBody.likedByUser
                    )
                }
                self.images.append(contentsOf: newImages)
                self.lastLoadedPage += 1

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: nil
                )
            case .failure(let error):
                self.logger.error("fetchImagesNextPage failed: \(error.localizedDescription)")
            }
            
            if self.task === task { self.task = nil }
        }
        self.task = task
        task?.resume()
    }
    
    func changeLike(imageId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard let token = OAuth2TokenStorage.token else {
            logger.error("changeLike: NetworkError.invalidRequest - missing OAuth token")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        guard let request = makeChangeLikeRequest(token: token, imageId: imageId, isLike: isLike) else {
            logger.error("changeLike: NetworkError.invalidRequest - unable to build URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        URLSession.shared.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self else { return }

            switch result {
            case .success:
                if let index = self.images.firstIndex(where: { $0.id == imageId }) {
                    self.images[index].isLiked = isLike
                }
                completion( .success(()) )
            case .failure(let error):
                self.logger.error("changeLike failed with imageId = \(imageId): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
