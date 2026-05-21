import Foundation

struct UrlsResult: Decodable {
    let fullUrl: URL
    let regularUrl: URL

    enum CodingKeys: String, CodingKey {
        case fullUrl = "full"
        case regularUrl = "regular"
    }
}
