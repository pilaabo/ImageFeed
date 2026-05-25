import Foundation
@testable import ImageFeed
internal import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []

    var viewDidLoadCalled = false
    var willDisplayRowCalled = false
    var lastWillDisplayIndexPath: IndexPath?
    var didTapLikeCalled = false
    var lastLikeIndexPath: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }

    func willDisplayRow(at indexPath: IndexPath) {
        willDisplayRowCalled = true
        lastWillDisplayIndexPath = indexPath
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
        lastLikeIndexPath = indexPath
    }
}
