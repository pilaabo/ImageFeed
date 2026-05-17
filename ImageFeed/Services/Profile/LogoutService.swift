import UIKit
import WebKit

final class LogoutService {
    static let shared = LogoutService()

    private init() { }

    func logout() {
        OAuth2TokenStorage.token = nil
        cleanCookies()

        ProfileService.shared.resetFetchedProfile()
        ProfileImageService.shared.resetFetchedProfileImageURL()
        ImagesListService.shared.resetFetchedImages()

        switchToSplashScreenController()
    }

    private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
    }

    private func switchToSplashScreenController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
        else { return }

        window.rootViewController = SplashViewController()
    }
}
