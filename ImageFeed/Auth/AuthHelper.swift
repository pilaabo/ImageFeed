import Foundation

final class AuthHelper: AuthHelperProtocol {
    // MARK: - Properties

    let configuration: AuthConfiguration

    // MARK: - Initialization

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    // MARK: - AuthHelperProtocol

    func makeAuthRequest() -> URLRequest {
        let url = makeAuthUrl()

        return URLRequest(url: url)
    }

    func extractAuthCode(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }

    // MARK: - Internal Methods

    func makeAuthUrl() -> URL {
        guard var urlComponents = URLComponents(string: configuration.unsplashAuthorizeURLString) else {
            preconditionFailure("Invalid unsplashAuthorizeURLString: \(configuration.unsplashAuthorizeURLString)")
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]

        guard let url = urlComponents.url else {
            preconditionFailure("Failed to build URL from components: \(urlComponents)")
        }

        return url
    }
}

// MARK: - AuthHelperProtocol

protocol AuthHelperProtocol {
    func makeAuthRequest() -> URLRequest
    func extractAuthCode(from url: URL) -> String?
}
