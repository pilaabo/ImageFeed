import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Properties

    weak var view: WebViewViewControllerProtocol?

    var authHelper: AuthHelperProtocol

    // MARK: - initializer

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    // MARK: - WebViewPresenterProtocol

    func viewDidLoad() {
        let request = authHelper.makeAuthRequest()
        view?.load(request: request)

        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func extractAuthCode(from url: URL) -> String? {
        authHelper.extractAuthCode(from: url)
    }

    // MARK: - Internal Methods

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    // MARK: - Private Methods

    private func makeAuthRequest() -> URLRequest {
        guard var urlComponents = URLComponents(string: AuthConfiguration.standard.unsplashAuthorizeURLString) else {
            preconditionFailure("Invalid unsplashAuthorizeURLString: \(AuthConfiguration.standard.unsplashAuthorizeURLString)")
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standard.accessKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standard.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AuthConfiguration.standard.accessScope),
        ]

        guard let url = urlComponents.url else {
            preconditionFailure("Failed to build URL from components: \(urlComponents)")
        }

        return URLRequest(url: url)
    }
}

// MARK: - WebViewPresenterProtocol

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }

    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func extractAuthCode(from url: URL) -> String?
}
