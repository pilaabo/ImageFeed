import XCTest

final class ImageFeedUITests: XCTestCase {
    private static let timeout: TimeInterval = 10

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: ImageFeedUITests.timeout))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: ImageFeedUITests.timeout))

        loginTextField.tap()
        loginTextField.typeText("EMAIL")
        dismissKeyboard()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: ImageFeedUITests.timeout))

        passwordTextField.tap()
        passwordTextField.typeText("PASSWORD")
        dismissKeyboard()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: ImageFeedUITests.timeout))
    }

    func testFeed() throws {
        let table = app.tables
        XCTAssertTrue(table.element.waitForExistence(timeout: ImageFeedUITests.timeout))

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: ImageFeedUITests.timeout))
        firstCell.swipeUp()

        let cellToLike = table.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: ImageFeedUITests.timeout))
        cellToLike.buttons["not liked button"].tap()
        cellToLike.buttons["liked button"].tap()
        cellToLike.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: ImageFeedUITests.timeout))

        image.pinch(withScale: 1.5, velocity: 1)

        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonButton = app.buttons["Back Button"]
        XCTAssertTrue(navBackButtonButton.waitForExistence(timeout: ImageFeedUITests.timeout))
        navBackButtonButton.tap()

        XCTAssertTrue(table.element.waitForExistence(timeout: ImageFeedUITests.timeout))
    }

    func testProfile() throws {
        let table = app.tables
        XCTAssertTrue(table.element.waitForExistence(timeout: Self.timeout))

        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: Self.timeout))
        profileTab.tap()

        let displayName = app.staticTexts["NAME"]
        XCTAssertTrue(displayName.waitForExistence(timeout: Self.timeout))
        XCTAssertTrue(app.staticTexts["@pilaabo"].exists)

        app.buttons["Logout button"].tap()

        let confirmButton = app.alerts["Пока, пока!"].buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: Self.timeout))
        confirmButton.tap()

        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: Self.timeout))
    }

    private func dismissKeyboard() {
        let doneTitles = ["Done", "Готово"]
        for title in doneTitles {
            let button = app.toolbars.buttons[title]
            if button.exists {
                button.tap()
                return
            }
        }
    }
}
