import UIKit

final class SplashViewController: UIViewController {
    // MARK: - UI Elements

    private lazy var splashScreenLogoView: UIImageView = {
        let splashScreen = UIImage(resource: .logo)
        let splashScreenLogoView = UIImageView(image: splashScreen)
        return splashScreenLogoView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = OAuth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let authViewController: AuthViewController = storyboard.instantiateViewController(identifier: "AuthViewController")
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }

    // MARK: - Setup UI

    private func setupViews() {
        view.backgroundColor = .background
        view.addSubview(splashScreenLogoView)
    }

    private func setupConstraints() {
        splashScreenLogoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashScreenLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Private Methods

    private func switchToTabBarController() {
        guard let window = view.window else { return }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()

        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(token: token, username: profile.loginName, { _ in })
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()

        guard let token = OAuth2TokenStorage.token else { return }

        fetchProfile(token: token)
    }
}
