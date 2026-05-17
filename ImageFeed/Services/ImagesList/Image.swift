import Foundation

struct Image {
    let id: String
    let size: CGSize
    let createdAt: Date
    let description: String?
    let regularImageURL: URL
    let largeImageURL: URL
    var isLiked: Bool
}
