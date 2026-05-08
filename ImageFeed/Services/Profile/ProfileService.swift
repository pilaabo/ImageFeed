import Foundation
import Logging

final class ProfileService {
    static let shared = ProfileService()

    private init() {}

    private let logger = Logger(label: "ProfileService")

    private(set) var profile: Profile?

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

        var task: URLSessionTask?
        task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<ProfileResponseBody, Error>) in

            guard let self else { return }

            switch result {
            case .success(let dto):
                let fullName = [dto.firstName, dto.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                let profile = Profile(
                    name: fullName,
                    loginName: dto.username,
                    bio: dto.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                self.logger.error("fetchProfile failed: \(error.localizedDescription)")
                completion(.failure(error))
            }

            if self.task === task { self.task = nil }
        }
        self.task = task
        task?.resume()
    }
}

