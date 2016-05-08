//
//  PushupInterfaceController.swift
//  Vague
//
//  Created by Rajashekara Rajashekara on 5/6/16.
//  Copyright © 2016 lab1. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion


class PushupInterfaceController: WKInterfaceController, WCSessionDelegate  {
    
    var applicationDict = [String: String]()

    
    var session : WCSession!
    
    let motionManager = CMMotionManager()
    
    var goalPushups = 0
    
    @IBOutlet var label: WKInterfaceLabel!
        
    var end = false
    
    @IBAction func stopWorkout() {
        
        // get the current date and time
        let currentDateTime = NSDate()
        
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: currentDateTime)
        
        // now the components are available
        let endHour = dateTimeComponents.hour   // 17
        let endMinute = dateTimeComponents.minute // 41
        let endSecond = dateTimeComponents.second // 57
        
        applicationDict["endSecond"] = String(endSecond)
        applicationDict["endMinute"] =  String(endMinute)
        applicationDict["endHour"] =  String(endHour)
        
    }
    
    
    @IBAction func startWorkout() {
        
        // get the current date and time
        let currentDateTime = NSDate()
        
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: currentDateTime)
        
        // now the components are available
            let startHour = dateTimeComponents.hour   // 17
            let startMinute = dateTimeComponents.minute // 41
            let startSecond = dateTimeComponents.second // 57
        
        
            applicationDict["startSecond"] = String(startSecond)
            applicationDict["startMinute"] =  String(startMinute)
            applicationDict["startHour"] =  String(startHour)
            
            let bundle = NSBundle.mainBundle()
            let path = bundle.pathForResource("featureVector", ofType: "txt")
            var lines = [String]()
            
            do {
                let content = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding) as String
                lines = content.componentsSeparatedByString("\n")
            }
            catch {/* error handling here */}
            
            var dataSet = [[Double]]()
            var labels = [String]()
            
            for i in 1...(lines.count-1){
                let eachFeature = String(lines[i]).componentsSeparatedByString(",")
                dataSet.append([Double(eachFeature[0])!,Double(eachFeature[1])!,Double(eachFeature[2])!,Double(eachFeature[3])!,Double(eachFeature[4])!,Double(eachFeature[5])!,Double(eachFeature[6])!])
                labels.append(eachFeature[7])
                //            print("Still working")
            }
            
            var sample = 0
            var array1 = [Double]()
            var counted = false
            var counter = 0
            var up = false
            
            if motionManager.accelerometerAvailable {
                let handler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                    sample += 1
                    array1.append(Double(data!.acceleration.y))
                    //                print(data!.acceleration.y)
//                    print(Double(data!.acceleration.x),",",Double(data!.acceleration.y),",",Double(data!.acceleration.z),",",sample)
                    
                    if(data!.acceleration.y > 0.50 && data!.acceleration.x < 0.80){
                        up = true
                    }
                    
                    if(data!.acceleration.y < 0.50 && up == true && data!.acceleration.x > 0.80){
                        counter += 1
                        
                        if(self.goalPushups - counter == 0){
                            self.applicationDict["pushups"] = String(0)
                            WKInterfaceDevice().playHaptic(.Notification)
                        }else if(self.goalPushups - counter > 0){
                            self.applicationDict["pushups"] = String(self.goalPushups - counter)
                            up = false
                            self.label.setText(String(self.goalPushups - counter))
                            sleep(1)
                        }else{
                            
                            up = false
                            self.label.setText(String(counter - self.goalPushups))
                        }
                    }
                }
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
            }else {
                label.setText("not available")
            }
            
            
            // DONT TOUCH THIS
            
            //        print("was able to append to dataset")
            
            //        if motionManager.accelerometerAvailable {
            //            let handler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
            //                sample += 1
            //                array1.append(Double(data!.acceleration.y))
            ////                print(data!.acceleration.y)
            //                print(Double(data!.acceleration.y),",",sample)
            //
            //                if(sample >= 10 && array1.count > 10){
            ////                print(Sigma.average(array1)!,",",Sigma.median(array1)!,",",Sigma.max(array1)!,",",Sigma.min(array1)!,",",Sigma.max(array1)!-Sigma.min(array1)!,",",Sigma.standardDeviationSample(array1)!,",",Sigma.varianceSample(array1)!,",",1)
            //
            //                    if(self.KNN([Sigma.average(array1)!,Sigma.median(array1)!,Sigma.max(array1)!,Sigma.min(array1)!,Sigma.max(array1)!-Sigma.min(array1)!,Sigma.standardDeviationSample(array1)!,Sigma.varianceSample(array1)!],dataSet: dataSet,labels: labels,k: 19) == 1){
            //                        counter += 1
            //                        self.label.setText(String(self.goalPushups - counter))
            //                        array1 = []
            //                    }else{
            //                        array1.removeFirst()
            //                    }
            //                }
            //            }
            //            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
            //        }else {
            //            label.setText("not available")
            //        }
//        }
        
        

    }
    

    
    override init() {
        super.init()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        motionManager.accelerometerUpdateInterval = 0.2

        // Configure interface objects here.
        var dict = context as! NSDictionary!
        if dict != nil {
            var segue = dict!["segue"]!
            var data = dict!["data"]! as? AnyObject!
            
            applicationDict["pushups"] = String(data!["pushups"]!)
            applicationDict["squats"] = String(data!["squats"]!)
            applicationDict["crunches"] =  String(data!["crunches"]!) as! String!

            self.label.setText(applicationDict["pushups"]!)//            print(String(data!["pushups"]!!))
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(session: WCSession, applicationContext: [String : AnyObject]) {
        let pushups = applicationContext["pushups"] as! String
        let squats = applicationContext["squats"] as! String
        let crunches = applicationContext["crunches"] as! String
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            print(pushups)
            self.label.setText(pushups)
            self.label.setText(squats)
            self.label.setText(crunches)
        }
    }
    
//    func send(count: [String]) {
//        do {
//            try session.updateApplicationContext(applicationDict)
//        } catch {
//            print("error")
//        }
//    }
//    
    func KNN(newFeatureVector: [Double],dataSet: [[Double]],labels: [String],k: Int) -> Int{
        
        // First make an array of arrays with the same size as the dataset
        let dataSetSize = dataSet.count
        var longMat = [[Double]]()
        var diffMat = [Double]()
        var sortedDiffMat = [Double]()
        var sortedDiffIndices = [Int]()
        var classCount:[String:Int] = [:]
        
        for _ in 0...(dataSetSize-1){
            longMat.append(newFeatureVector)
        }
        
        for i in 0...(dataSetSize-1){
            var eachMat = [Double]()
            for j in 0...(newFeatureVector.count-1){
                eachMat.append((longMat[i][j]-dataSet[i][j])*(longMat[i][j]-dataSet[i][j]))
            }
            diffMat.append(sqrt(Sigma.sum(eachMat)))
            sortedDiffMat = diffMat.sort()
        }
        
        for x in 0...(diffMat.count-1){
            let something = diffMat.indexOf({$0==sortedDiffMat[x]})
            sortedDiffIndices.append(Int(something!))
        }
        
        classCount["0"] = 0
        classCount["1"] = 0
        
        for i in 0...(k-1){
            let voteIlabel = String(labels[sortedDiffIndices[i]])
            
            if ((classCount[voteIlabel]) != nil) {
                // now val is not nil and the Optional has been unwrapped, so use it
                classCount[voteIlabel] = classCount[voteIlabel]! + 1
            }
        }
        
//        print(classCount)
        
        if(classCount["1"]>=18) {
            return 1
        }else{
            return 0
        }
    }
    
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) ->
        AnyObject? {
            if segueIdentifier == "hierarchical" {
                return ["segue": "hierarchical",
                        "data":"Passed through hierarchical navigation"]
            } else if segueIdentifier == "pagebased" {
                return ["segue": "pagebased",
                        "data": "Passed through page-based navigation"]
            } else {
                return ["segue": "", "data": applicationDict]
            }
    }

}
