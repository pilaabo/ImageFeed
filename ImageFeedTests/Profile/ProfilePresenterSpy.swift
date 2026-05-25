import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?

    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var didConfirmLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}
