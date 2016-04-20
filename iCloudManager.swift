//
//  iCloudManager.swift
//  Vague
//
//  Created by Rajashekara Rajashekara on 4/16/16.
//  Copyright © 2016 lab1. All rights reserved.
//
import UIKit

public protocol iCloudUpdateDelegate {
    func iCloudUpdated() -> Void
}

public class iCloudManager: NSObject {
    
    public var iCloudDelegate: iCloudUpdateDelegate?

    public override init () {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iCloudChanged), name:
            NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
    }
    
    public func iCloudChanged(notification: NSNotification) -> Void {
        if let callback = iCloudDelegate {
            callback.iCloudUpdated()
        }
    }
    
    public func getiCloudData(key: String) -> String {
        if let countStr = NSUbiquitousKeyValueStore.defaultStore().objectForKey(key) {
            return countStr as! String;
        }
        else
        {
            return "0";
        }
        
    }
    
    public func setiCloudData(key: String, values: String?) -> Void {
        NSUbiquitousKeyValueStore.defaultStore().setObject(values, forKey: key)
    }
    
}
