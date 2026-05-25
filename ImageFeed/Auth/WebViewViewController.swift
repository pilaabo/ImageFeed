import UIKit
import WebKit

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    // MARK: - Outlets

    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var progressView: UIProgressView?

    // MARK: - Properties

    private var presenter: WebViewPresenterProtocol!
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Configuration

    func configure(_ presenter: WebViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.accessibilityIdentifier = "UnsplashWebView" // для тестов

        webView?.navigationDelegate = self

        setupProgressObservation()

        presenter.viewDidLoad()
    }

    // MARK: - WebViewViewControllerProtocol

    func load(request: URLRequest) {
        webView?.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView?.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView?.isHidden = isHidden
    }

    // MARK: - Private Methods

    private func setupProgressObservation() {
        estimatedProgressObservation = webView?.observe(
            \.estimatedProgress,
            options: []
        ) { [weak self] _, _ in
            guard let self else { return }
            self.presenter.didUpdateProgressValue(self.webView?.estimatedProgress ?? 0)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
          if let code = code(from: navigationAction) {
              decisionHandler(.cancel)
              delegate?.webViewViewController(self, didAuthenticateWithCode: code)
          } else {
              decisionHandler(.allow)
          }
      }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else { return nil }

        return presenter.extractAuthCode(from: url)
    }
}

// MARK: - WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)

    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewControllerProtocol

protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)

    func setProgressValue(_ newValue: Float)

    func setProgressHidden(_ isHidden: Bool)
}
