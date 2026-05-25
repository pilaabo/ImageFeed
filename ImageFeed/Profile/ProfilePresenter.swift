import Foundation
import Logging

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Properties

    weak var view: ProfileViewControllerProtocol?

    private let logger = Logger(label: "ProfilePresenter")
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - ProfilePresenterProtocol

    func viewDidLoad() {
        if let profile = ProfileService.shared.profile {
            renderProfile(profile)
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }

    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }

    func didConfirmLogout() {
        LogoutService.shared.logout()
    }

    // MARK: - Private Methods

    private func renderProfile(_ profile: Profile) {
        let name = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        let loginName = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : "@\(profile.loginName)"
        let bio = profile.bio.isEmpty
            ? "Профиль не заполнен"
            : profile.bio
        view?.updateProfileDetails(name: name, loginName: loginName, bio: bio)
    }

    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.profileImageURL else {
            logger.debug("updateAvatar: profileImageURL is nil, skipping")
            view?.updateAvatar(url: nil)
            return
        }
        guard let url = URL(string: profileImageURL) else {
            logger.error("updateAvatar: failed to build URL from '\(profileImageURL)'")
            return
        }
        view?.updateAvatar(url: url)
    }
}

// MARK: - ProfileViewControllerProtocol

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(url: URL?)
    func showLogoutConfirmation()
}

// MARK: - ProfilePresenterProtocol

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
    func didTapLogoutButton()
    func didConfirmLogout()
}
