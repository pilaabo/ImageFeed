import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var lastUpdateOldCount: Int?
    var lastUpdateNewCount: Int?

    var reloadRowCalled = false
    var lastReloadIndexPath: IndexPath?

    var setLoadingCalled = false
    var lastIsLoading: Bool?

    var showLikeErrorCalled = false

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        lastUpdateOldCount = oldCount
        lastUpdateNewCount = newCount
    }

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        lastReloadIndexPath = indexPath
    }

    func setLoading(_ isLoading: Bool) {
        setLoadingCalled = true
        lastIsLoading = isLoading
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }
}
