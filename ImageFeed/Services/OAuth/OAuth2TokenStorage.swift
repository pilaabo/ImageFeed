import Foundation
import SwiftKeychainWrapper

enum OAuth2TokenStorage {
    private static let tokenKey = "token"

    static var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
}
