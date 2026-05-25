import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Arrange
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.configure(presenter)

        // Act
        _ = viewController.view

        // Assert
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // Arrange
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let viewController = WebViewViewControllerSpy()
        presenter.view = viewController

        // Act
        presenter.viewDidLoad()

        // Assert
        XCTAssertTrue(viewController.loadCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        // Arrange
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // Act
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // Assert
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        // Arrange
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1

        // Act
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // Assert
        XCTAssertTrue(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        // Arrange
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        // Act
        let request = authHelper.makeAuthRequest()

        // Assert
        guard let urlString = request.url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        XCTAssertTrue(urlString.contains(configuration.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        // Arrange
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!

        // Act
        let code = authHelper.extractAuthCode(from: url)

        // Assert
        XCTAssertEqual(code, "test code")
    }
}
