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
            URLQueryItem(name: "per_page", value: "\(imagesPerPage)")
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
                        thumbImageURL: imageResponseBody.urls.thumb,
                        largeImageURL: imageResponseBody.urls.full,
                        isLiked: imageResponseBody.likedByUser
                    )
                }
                self.images.append(contentsOf: newImages)
                self.lastLoadedPage += 1

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["images": self.images]
                )
            case .failure(let error):
                self.logger.error("fetchImagesNextPage failed: \(error.localizedDescription)")
            }
            
            if self.task === task { self.task = nil }
        }
        self.task = task
        task?.resume()
    }
}
