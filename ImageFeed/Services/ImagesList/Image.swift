import Foundation

struct Image {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: URL
    let regularImageURL: URL
    let largeImageURL: URL
    let isLiked: Bool
}
