import WatchKit
import Foundation
import CoreMotion

class SquatsInterfaceController: WKInterfaceController {
    
    var goalPushups = 0
    
    var applicationDict = [String: String]()
    
    @IBOutlet var label: WKInterfaceLabel!
    
    @IBAction func startWorkout() {
        var sample = 0
        var array1 = [Double]()
        var counter = 0
        var down = false
        
        if motionManager.accelerometerAvailable {
            let handler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                sample += 1
//                array1.append(Double(data!.acceleration.y))
//                                print(data!.acceleration.y)
                print(Double(data!.acceleration.x),",",Double(data!.acceleration.y),",",Double(data!.acceleration.z),",",sample)
                
                if(data!.acceleration.z < -1.25){
                    down = true
                }
                
                if(data!.acceleration.z > -1 && down == true){
                    down = false
                    counter += 1
                    self.label.setText(String(self.goalPushups - counter))
                    sleep(1)
                }
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }else {
            label.setText("not available")
        }
    }
    
    let motionManager = CMMotionManager()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        motionManager.accelerometerUpdateInterval = 0.2
        
        var dict = context as! NSDictionary!
        if dict != nil {
            var segue = dict["segue"]!
            var data = dict
            ["data"] as? AnyObject!
            
            applicationDict["pushups"] = String(data!["pushups"])
            applicationDict["squats"] = String(data!["squats"])
            applicationDict["crunches"] =  String(data!["crunches"]) as String
            
            let something = String(data!["squats"])
            self.label.setText(something)
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

}
