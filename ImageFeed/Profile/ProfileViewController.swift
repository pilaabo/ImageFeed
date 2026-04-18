import UIKit
import Logging

final class ProfileViewController: UIViewController {

    // MARK: - Private Properties

    private let logger = Logger(label: "ProfileViewController")

    // MARK: - UI Elements
    
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImage(resource: .mockProfileAvatar)
        let profileImageView = UIImageView(image: profileImage)
        return profileImageView
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let displayNameLabel = UILabel()
        displayNameLabel.text = "Екатерина Новикова"
        displayNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        displayNameLabel.textColor = .white
        return displayNameLabel
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(red: 174/255.0, green: 175/255.0, blue: 180/255.0, alpha: 1.0)
        return loginNameLabel
    }()
    
    private lazy var bioLabel: UILabel = {
        let bioLabel = UILabel()
        bioLabel.text = "Hello, world!"
        bioLabel.font = UIFont.systemFont(ofSize: 13)
        bioLabel.textColor = .white
        return bioLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.setImage(.logout, for: .normal)
        logoutButton.tintColor = UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0)
        return logoutButton
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        guard let token = OAuth2TokenStorage.token else { return }
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            switch (result) {
            case .success(let profile):
                updateProfileDetails(profile: profile)
            case .failure(let error):
                logger.error("fetchProfile failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods

    private func updateProfileDetails(profile: Profile) {
        displayNameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        bioLabel.text = profile.bio.isEmpty
            ? "Профиль не заполнен"
            : profile.bio
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(displayNameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }
    
    // MARK: - Setup Constraints

    private func setupConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            displayNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            displayNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 8),
            
            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
