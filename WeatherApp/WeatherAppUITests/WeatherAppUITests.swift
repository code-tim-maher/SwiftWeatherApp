//
//  WeatherAppUITests.swift
//  WeatherAppUITests
//
//  Created by Tim Maher on 7/22/23.
//

import XCTest

final class WeatherAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCityEntryAndRoutetoWeatherDetails() throws {
       
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        
        // check that if the app is in a state in which we preloaded a location and showing weather details screen, if so swipe down.
        let iconImageView = app.images["iconImageView"]
        if iconImageView.exists {
            iconImageView.swipeDown(velocity: .fast)
        }
        
        // Find search bar, enter "boston"
        let searchBar = app.searchFields.firstMatch
        searchBar.tap()
        searchBar.typeText("Boston")
       
        // Tap on first tableRow of suggestions
        let allCells = app.cells
        let firstCell = allCells.containing(.cell, identifier: "tableRow_0").firstMatch
        firstCell.tap()
        
        sleep(5)

        // Assert that we are takien to Weather Details view.
        let weatherDetailIconImageView = app.images["iconImageView"]
        XCTAssert(weatherDetailIconImageView.exists)
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
