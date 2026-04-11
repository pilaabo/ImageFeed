import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - failed to create URLComponents from 'https://unsplash.com/oauth/token'")
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
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - failed to build URL from URLComponents: \(urlComponents)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }

    func fetchOAuthToken(
        from code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service.fetchOAuthToken]: NetworkError.invalidRequest - unable to build URLRequest for code: \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("[OAuth2Service.fetchOAuthToken]: NetworkError.decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: Network request failed - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
