import Foundation
import Logging

final class OAuth2Service {
    // MARK: - Properties

    static let shared = OAuth2Service()

    private let logger = Logger(label: "OAuth2Service")

    private var task: URLSessionTask?
    private var lastCode: String?

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    func fetchOAuthToken(
        from code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            logger.error("fetchOAuthToken failed - duplicate authorization code, request already in progress")
            completion(.failure(NetworkError.duplicateRequest))
            return
        }
        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            logger.error("fetchOAuthToken: NetworkError.invalidRequest - unable to build URLRequest for code: \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var task: URLSessionTask?
        task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }

            switch result {
            case .success(let dto):
                OAuth2TokenStorage.token = dto.accessToken
                completion(.success(dto.accessToken))
            case .failure(let error):
                self.logger.error("fetchOAuthToken failed: \(error.localizedDescription)")
                completion(.failure(error))
            }

            if self.task === task {
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task?.resume()
    }

    // MARK: - Private Methods

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let urlString = "https://unsplash.com/oauth/token"
        guard var urlComponents = URLComponents(string: urlString) else {
            logger.error("makeOAuthTokenRequest: failed to create URLComponents from '\(urlString)'")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standard.accessKey),
            URLQueryItem(name: "client_secret", value: AuthConfiguration.standard.secretKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standard.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = urlComponents.url else {
            logger.error("makeOAuthTokenRequest: failed to build URL from URLComponents: \(urlComponents)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

        return request
    }
}
