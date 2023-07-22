//
//  GeocoderUtilitiesTests.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import XCTest
@testable import WeatherService

final class GeocoderUtilitiesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testZipCodeDetection() throws {
        let validZipCode = "12345"
        let zipCodeTooShort = "1234"
        let zipCodeTooLong = "123456"
        let zipCodeHasChar = "12X45"
                
        XCTAssertEqual(QueryType.zip, GeocoderUtilities.queryType(_forString: validZipCode))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: zipCodeTooShort))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: zipCodeTooLong))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: zipCodeHasChar))
    }

    func testCityStateDetection() throws {
        let validCityState = "Las Vegas, NV"
        let stateNotTwoCharCode = "Las Vegas, Nevada"
        let stateNotFound = "Las Vegas"
        let noSpaceInString = "Las Vegas,NV"
        let noCommaInString = "LAs Vegas NV"
        
        XCTAssertEqual(QueryType.cityState, GeocoderUtilities.queryType(_forString: validCityState))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: stateNotTwoCharCode))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: stateNotFound))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: noSpaceInString))
        XCTAssertEqual(QueryType.unknown, GeocoderUtilities.queryType(_forString: noCommaInString))

    }

}
