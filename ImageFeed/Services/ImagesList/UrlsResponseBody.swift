import Foundation

struct UrlsResponseBody: Decodable {
    let full: URL
    let regular: URL
    let thumb: URL
}
