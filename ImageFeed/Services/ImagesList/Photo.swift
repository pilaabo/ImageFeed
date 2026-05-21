import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let regularImageURL: URL
    let largeImageURL: URL
    let isLiked: Bool
}

extension Photo {
    func withIsLiked(_ isLiked: Bool) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            description: description,
            regularImageURL: regularImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
