import Foundation
import Logging

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    private init() {
        
    }
    
    private let logger = Logger(label: "ProfileImageService")

    private(set) var profileImageURL: String?

    private var task: URLSessionTask?
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        let urlString = Constants.defaultBaseURLString + "/users/\(username)"
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileImageRequest(token: token, username: username) else {
            logger.error("fetchProfileImageURL: NetworkError.invalidRequest - unable to build URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var task: URLSessionTask?
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let dto):
                let url = dto.profileImage.small
                self.profileImageURL = url
                completion(.success(url))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": url]
                )
            case .failure(let error):
                self.logger.error("fetchProfileImageURL failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            if self.task === task { self.task = nil }
        }
        self.task = task
        task?.resume()
    }
}
