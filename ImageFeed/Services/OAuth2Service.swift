import Foundation
import Logging

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let logger = Logger(label: "OAuth2Service")
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let urlString = "https://unsplash.com/oauth/token"
        guard var urlComponents = URLComponents(string: urlString) else {
            logger.error("makeOAuthTokenRequest: failed to create URLComponents from '\(urlString)'")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
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

    func fetchOAuthToken(
        from code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            logger.error("fetchOAuthToken failed - duplicate authorization code, request already in progress")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            logger.error("fetchOAuthToken: NetworkError.invalidRequest - unable to build URLRequest for code: \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let responseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                } catch {
                    self.logger.error("fetchOAuthToken: NetworkError.decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                self.logger.error("fetchOAuthToken: network request failed - \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}
