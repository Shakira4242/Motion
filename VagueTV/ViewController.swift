//
//  ViewController.swift
//  VagueTV
//
//  Created by Rajashekara Rajashekara on 4/16/16.
//  Copyright © 2016 lab1. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, iCloudUpdateDelegate {
    
    let motivationalQuotes = "\"I've failed over and over again in my life, and that is why I succeed - Michael Jordan\""
    
    @IBOutlet weak var count: UILabel!
    
    var iCloud = iCloudManager()
    
    func iCloudUpdated() {
        // TODO get data I care about
        let updatedCount = iCloud.getiCloudData("count")
        
    }
    
    func setCountInIcloud(value: String) {
        iCloud.setiCloudData("count", values: value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

