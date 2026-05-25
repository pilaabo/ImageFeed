import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    private static let samplePhoto = Photo(
        id: "test",
        size: CGSize(width: 100, height: 100),
        createdAt: nil,
        description: nil,
        regularImageURL: URL(string: "https://unsplash.com")!,
        largeImageURL: URL(string: "https://unsplash.com")!,
        isLiked: false
    )

    func testViewControllerCallsViewDidLoad() {
        // Arrange
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        // Act
        _ = viewController.view

        // Assert
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testNumberOfRowsReflectsPresenterPhotos() {
        // Arrange
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.photos = Array(repeating: Self.samplePhoto, count: 5)
        viewController.configure(presenter)

        // Act
        let rows = viewController.tableView(UITableView(), numberOfRowsInSection: 0)

        // Assert
        XCTAssertEqual(rows, 5)
    }

    func testWillDisplayIsForwardedToPresenter() {
        // Arrange
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.photos = [Self.samplePhoto, Self.samplePhoto]
        viewController.configure(presenter)

        // Act
        viewController.tableView(
            UITableView(),
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 1, section: 0)
        )

        // Assert
        XCTAssertTrue(presenter.willDisplayRowCalled)
        XCTAssertEqual(presenter.lastWillDisplayIndexPath, IndexPath(row: 1, section: 0))
    }
}
