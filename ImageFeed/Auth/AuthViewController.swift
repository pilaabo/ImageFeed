import UIKit
import ProgressHUD
import Logging

final class AuthViewController: UIViewController {

    // MARK: - Properties

    private static let segueId = "ShowWebView"
    private let logger = Logger(label: "AuthViewController")

    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthViewController.segueId, let webVC = segue.destination as? WebViewViewController {
            webVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private Methods

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = .backward
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = .backward
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .background
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)

        UIBlockingProgressHUD.show()

        OAuth2Service.shared.fetchOAuthToken(from: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                self.logger.error("fetchOAuthToken failed - \(error.localizedDescription)")
                showErrorAlert(message: "Не удалось войти в систему")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
