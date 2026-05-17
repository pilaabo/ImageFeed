import Foundation

struct ImageResponseBody: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResponseBody
    let likedByUser: Bool
}
