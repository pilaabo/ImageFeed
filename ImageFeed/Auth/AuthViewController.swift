import UIKit

final class AuthViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView", let webVC = segue.destination as? WebViewViewController {
            webVC.delegate = self
            webVC.configure(WebViewPresenter(authHelper: AuthHelper()))
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
            case .failure:
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
