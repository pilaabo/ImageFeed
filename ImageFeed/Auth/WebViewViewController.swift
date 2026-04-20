import UIKit
import WebKit
import Logging

final class WebViewViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var progressView: UIProgressView?

    // MARK: - Properties

    weak var delegate: WebViewViewControllerDelegate?
    private let logger = Logger(label: "WebViewViewController")
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        webView?.navigationDelegate = self

        estimatedProgressObservation = webView?.observe(
            \.estimatedProgress,
            options: []
        ) { [weak self] _, _ in
            guard let self else { return }
            
            self.updateProgress()
        }
        loadAuthView()
    }

    // MARK: - Private Methods

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            logger.error("loadAuthView: failed to create URLComponents from \(Constants.unsplashAuthorizeURLString)")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]

        guard let url = urlComponents.url else {
            logger.error("loadAuthView: failed to build URL from URLComponents: \(urlComponents)")
            return
        }

        let request = URLRequest(url: url)
        webView?.load(request)
    }

    private func updateProgress() {
        guard let webView else { return }

        progressView?.progress = Float(webView.estimatedProgress)
        progressView?.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

// MARK: - WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
