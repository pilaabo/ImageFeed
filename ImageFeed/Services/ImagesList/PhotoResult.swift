import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}
