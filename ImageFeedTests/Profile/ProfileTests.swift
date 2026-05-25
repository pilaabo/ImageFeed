import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Arrange
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        // Act
        _ = viewController.view

        // Assert
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdateAvatarOnViewDidLoad() {
        // Arrange
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController

        // Act
        presenter.viewDidLoad()

        // Assert
        XCTAssertTrue(viewController.updateAvatarCalled)
    }

    func testPresenterShowsLogoutConfirmation() {
        // Arrange
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController

        // Act
        presenter.didTapLogoutButton()

        // Assert
        XCTAssertTrue(viewController.showLogoutConfirmationCalled)
    }
}
