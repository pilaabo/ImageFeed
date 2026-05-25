import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var lastName: String?
    var lastLoginName: String?
    var lastBio: String?

    var updateAvatarCalled = false
    var lastAvatarURL: URL?

    var showLogoutConfirmationCalled = false

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        lastName = name
        lastLoginName = loginName
        lastBio = bio
    }

    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
        lastAvatarURL = url
    }

    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
}
