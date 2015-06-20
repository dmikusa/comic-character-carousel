//
//  Comic_Character_CarouselTests.swift
//  Comic Character CarouselTests
//
//  Created by Daniel Mikusa on 6/11/15.
//  Copyright (c) 2015 Daniel Mikusa. All rights reserved.
//

import Cocoa
import XCTest
import SwiftyJSON
import BrightFutures
import Comic_Character_Carousel

class DataPagerTests: XCTestCase {
    
    var dp:DataPager? = nil
    
    override func setUp() {
        super.setUp()
        dp = DataPager(windowSize: 5) {
            (globalPos:Int, windowSize:Int) -> Future<(Int, [JSON])> in
            
            let promise = Promise<(Int, [JSON])>()
            let name = "data\(globalPos)to\(globalPos + windowSize)"
            if let resourcePath = NSBundle(forClass: self.dynamicType).pathForResource(name, ofType: "json") {
                let json = JSON(data: NSData(contentsOfFile: resourcePath)!)
                promise.success(json["total"].intValue, json["cc"].arrayValue)
            }
            return promise.future
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testToStart() {
        var expectation = self.expectationWithDescription("update w/data")
        dp!.toStart {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "3-D Man", "Name of first item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testToEndFails() {
        var expectation = self.expectationWithDescription("no update, need to call toStart first")
        dp!.toEnd {
            item in
            
            XCTAssertEqual(item, nil, "When no globalMax set, return nil")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testToEndOK() {
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("toEnd completed")
        dp!.toEnd {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajaxis", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testStepThroughItems() {
        // load initial set
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step to second item
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "A-Bomb (HAS)", "Name of second item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step to third item
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "A.I.M.", "Name of second item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step back to second item
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "A-Bomb (HAS)", "Name of second item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testStepBeforeFirst() {
        // load initial set
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // try to step back before the first item
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "3-D Man", "still at first item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testStepAfterLast() {
        // load initial set
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step to the end
        expectation = self.expectationWithDescription("toEnd completed")
        dp!.toEnd {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajaxis", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // try to step beyond the end
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajaxis", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testStepThroughToSecondPageAndBackToFirst() {
        // load initial set
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "3-D Man", "still at first item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step through the next seven items to make it page more data
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem { item in expectation.fulfill() }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem { item in expectation.fulfill() }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem { item in expectation.fulfill() }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Abomination (Emil Blonsky)", "fifth item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
        
            XCTAssertEqual(item["name"].stringValue, "Abomination (Ultimate)", "sixth item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in

            XCTAssertEqual(item["name"].stringValue, "Absorbing Man", "seventh item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // now step back to the first page
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in

            XCTAssertEqual(item["name"].stringValue, "Abomination (Ultimate)", "sixth item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Abomination (Emil Blonsky)", "fifth item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Aaron Stack", "fourth item")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
    
    func testToLastAndBackAPage() {
        // load initial set
        var expectation = self.expectationWithDescription("toStart completed")
        dp!.toStart {
            item in
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step to the end
        expectation = self.expectationWithDescription("toEnd completed")
        dp!.toEnd {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajaxis", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // try to step beyond the end
        expectation = self.expectationWithDescription("nextItem completes")
        dp!.nextItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajaxis", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        // step backwards until more data loads
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Ajak", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Air-Walker (Gabriel Lan)", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Aginar", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Agents of Atlas", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
        expectation = self.expectationWithDescription("prevItem completes")
        dp!.prevItem {
            item in
            
            XCTAssertEqual(item["name"].stringValue, "Agent Zero", "Name of last item matches")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.25, handler: nil)
    }
}
