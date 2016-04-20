//
//  PushupViewController.swift
//  Vague
//
//  Created by Rajashekara Rajashekara on 4/17/16.
//  Copyright © 2016 lab1. All rights reserved.
//

import UIKit

class PushupViewController: UIViewController {

    var iCloud = iCloudManager()
    
    func iCloudUpdated() {
        // TODO get data I care agout
        let updatedCount = iCloud.getiCloudData("count")
    }
    
    func setCountInIcloud(value: String) {
        iCloud.setiCloudData("count", values: value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
