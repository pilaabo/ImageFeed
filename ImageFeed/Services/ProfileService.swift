import Foundation
import Logging

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}

    private let logger = Logger(label: "ProfileService")

    private var task: URLSessionTask?

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURLString + "/me") else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            logger.error("fetchProfile: NetworkError.invalidRequest - unable to build URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<ProfileResponseBody, Error>) in

            guard let self else { return }

            switch result {
            case .success(let dto):
                let fullName = [dto.firstName, dto.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                let profile = Profile(
                    name: fullName,
                    loginName: "@\(dto.username)",
                    bio: dto.bio ?? ""
                )
                completion(.success(profile))
            case .failure(let error):
                self.logger.error("fetchProfile failed: \(error.localizedDescription)")
                completion(.failure(error))
            }

            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

struct ProfileResponseBody: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct Profile {
    let name: String
    let loginName: String
    let bio: String
}
