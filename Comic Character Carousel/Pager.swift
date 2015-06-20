//
//  Pager.swift
//  Comic Character Carousel
//
//  Created by Daniel Mikusa on 6/14/15.
//  Copyright (c) 2015 Daniel Mikusa. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures

public class DataPager {

    public var loadData:(Int, Int) -> Future<(Int, [JSON])>
    private var data:[JSON]
    private var globalPos:Int
    private var localPos:Int
    private var windowSize:Int
    private var globalMax:Int
    
    public init(windowSize:Int, loadData:(Int, Int) -> Future<(Int, [JSON])> = {a, c in return Promise<(Int, [JSON])>().future }) {
        self.globalPos = 0
        self.localPos = 0
        self.windowSize = windowSize
        self.loadData = loadData
        self.data = []
        self.globalMax = -1
        self.toStart({ item in })
    }
    
    public func toStart(ok: JSON -> Void) {
        globalPos = 0
        localPos = 0
        self.loadData(self.globalPos, self.windowSize).onSuccess {
            (globalMax, data) in
            
            self.globalMax = globalMax
            self.data = data
            ok(data[self.localPos])
        }
    }
    
    public func toEnd(ok: JSON -> Void) {
        if globalMax > 0 {
            globalPos = globalMax - 1
            localPos = windowSize - 1
            loadData(globalPos - localPos, windowSize).onSuccess {
                (globalMax, data) in
                
                self.globalMax = globalMax
                self.data = data
                ok(data[self.localPos])
            }
        } else {
            ok(nil)
        }
    }
    
    public func prevItem(ok: JSON -> Void = { item in }) {
        globalPos -= 1
        localPos -= 1
        var reload = false
        if globalPos < 0 {
            globalPos = 0
            localPos = 0
            reload = true
        }
        if localPos < 0 {
            localPos = windowSize - 1
            reload = true
        }
        if reload {
            loadData(globalPos - localPos, windowSize).onSuccess {
                (globalMax, data) in
                
                self.globalMax = globalMax
                self.data = data
                ok(data[self.localPos])
            }
        } else {
            ok(data[localPos])
        }
    }
    
    public func nextItem(ok: JSON -> Void) {
        globalPos += 1
        localPos += 1
        var windowShift = 0
        var reload = false
        if localPos > (data.count - 1) {
            localPos = 0
            reload = true
        }
        if globalPos >= globalMax {
            globalPos = globalMax - 1
            localPos = windowSize - 1
            windowShift = localPos
            reload = true
        }
        if reload {
            loadData(globalPos - windowShift, windowSize).onSuccess {
                (globalMax, data) in
                
                self.globalMax = globalMax
                self.data = data
                ok(data[self.localPos])
            }
        } else {
            ok(data[localPos])
        }
    }
    
}