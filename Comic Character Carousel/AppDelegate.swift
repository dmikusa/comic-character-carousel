//
//  AppDelegate.swift
//  Comic Character Carousel
//
//  Created by Daniel Mikusa on 6/11/15.
//  Copyright (c) 2015 Daniel Mikusa. All rights reserved.
//

import Cocoa
import Just
import SwiftyJSON
import BrightFutures

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var characterName: NSTextField!
    @IBOutlet weak var characterDescription: NSTextField!
    @IBOutlet weak var copyright: NSTextField!

    var pager:DataPager;
    
    override init() {
        pager = DataPager(windowSize: 20)
        super.init()
        pager.loadData = {
            (globalPos:Int, windowSize:Int) -> Future<(Int, [JSON])> in
            
            let promise = Promise<(Int, [JSON])>()
            
            Queue.global.async {
                Just.get("http://ccc-api.cfapps.io/", params: ["limit": windowSize, "offset": globalPos]) {
                    (r) in
                    
                    if r.ok {
                        let json = JSON(data: r.content!)
                        self.copyright.stringValue = json["attributionText"].stringValue
                        promise.success(json["total"].intValue, json["cc"].arrayValue)
                    }
                }
            }
            
            return promise.future
        }
    }

    func update(item:JSON) {
        self.characterName.stringValue = item["name"].stringValue
        if item["description"].stringValue == "" {
            self.characterDescription.stringValue = "No description available."
        } else {
            self.characterDescription.stringValue = item["description"].stringValue
        }
        var thumbnail = item["thumbnail"].stringValue
        if thumbnail == "" {
            thumbnail = "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available/portrait_uncanny.jpg"
        }
        self.imageView?.image = NSImage(contentsOfURL: NSURL(string: thumbnail)!)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        pager.toStart { item in self.update(item) }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    @IBAction func gotoFirst(sender: AnyObject) {
        pager.toStart { item in self.update(item) }
    }

    @IBAction func gotoPrevious(sender: AnyObject) {
        pager.prevItem { item in self.update(item) }
    }
    
    @IBAction func gotoNext(sender: AnyObject) {
        pager.nextItem { item in self.update(item) }
    }
    
    @IBAction func gotoLast(sender: AnyObject) {
        pager.toEnd { item in self.update(item) }
    }
}

