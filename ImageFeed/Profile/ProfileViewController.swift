import UIKit
import Logging
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Properties

    private var presenter: ProfilePresenterProtocol!

    private let logger = Logger(label: "ProfileViewController")

    private static let avatarSize: CGFloat = 70
    private static let placeholderAvatar = UIImage(resource: .mockProfileAvatar)

    // MARK: - Configuration

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - UI Elements

    private lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: Self.placeholderAvatar)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .subtitleGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.setImage(.logout, for: .normal)
        logoutButton.tintColor = .logoutRed
        logoutButton.accessibilityIdentifier = "Logout button"
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addAction(
            UIAction { [weak self] _ in self?.presenter.didTapLogoutButton() },
            for: .touchUpInside
        )
        return logoutButton
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()

        presenter.viewDidLoad()
    }

    // MARK: - ProfileViewControllerProtocol

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = loginName
        bioLabel.text = bio
    }

    func updateAvatar(url: URL?) {
        guard let url else {
            profileImageView.image = Self.placeholderAvatar
            return
        }
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            options: [.processor(RoundCornerImageProcessor(cornerRadius: Self.avatarSize / 2))]
        ) { [weak self] result in
            if case .failure(let error) = result {
                self?.logger.error("avatar load failed - \(error.localizedDescription)")
            }
        }
    }

    func showLogoutConfirmation() {
        showAlert(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            actions: [
                UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                    self?.presenter.didConfirmLogout()
                },
                UIAlertAction(title: "Нет", style: .cancel),
            ]
        )
    }

    // MARK: - Setup UI

    private func setupViews() {
        view.backgroundColor = .background
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: Self.avatarSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Self.avatarSize),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),

            loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),

            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
