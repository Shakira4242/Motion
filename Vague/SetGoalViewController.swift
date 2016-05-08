import UIKit
import Firebase
import WatchConnectivity
import WatchKit

class setGoalViewController: UIViewController, WCSessionDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var goalName: UITextField!
    
    
    var session : WCSession!
    
    var ref = Firebase(url: "https://motionapp.firebaseio.com/")
    
    var pickerData: [[String]] = [[String]]()
    
    var position = [0,0,0]
    
    var applicationDict = [String: String]()
    
    // Will add a new goal which consists of:
    // 1. Reps for Pushups, Crunches, Situps etc ....
    // 2. Timestamp of when the goal was set
    // (Optional) 3. Date to be completed
    
    // This should also ....
    // update the counters on the apple watch!
    
    @IBAction func addGoal(sender: AnyObject) {
        // get current hour and minutes
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        
        print(hour)
        print(minutes)
        
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                var ref = "https://motionapp.firebaseio.com/Users/" + (authData.uid) + "/goals/" + self.goalName.text!
                var something = Firebase(url: ref)
                something.childByAppendingPath("startTime").setValue(["hours": hour,"minutes": minutes])
                something.childByAppendingPath("expired").setValue("false")
                something.childByAppendingPath("endTime").setValue(["hours": hour+1,"minutes": minutes])
                something.childByAppendingPath("workout").setValue(["pushups": self.pickerData[0][self.position[0]],"squats": self.pickerData[1][self.position[1]],"crunches":  self.pickerData[2][self.position[2]]])
                self.send([self.pickerData[0][self.position[0]],self.pickerData[1][self.position[1]],self.pickerData[2][self.position[2]]])
            } else {
                // No user is signed in
            }
        })
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData[0].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickerData[component][row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.

        position[component] = row
    }
    
    @IBOutlet weak var profile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var color = UIColor(netHex:0x11293a)
        self.view.backgroundColor = color
                
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = [["10","20","30","40","50","100"],["10","20","30","40","50","100"],["10","20","30","40","50","100"]]
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
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func send(count: [String]) {
        applicationDict["pushups"] = count[0]
        applicationDict["squats"] = count[1]
        applicationDict["crunches"] = count[2]
        do {
            try session.updateApplicationContext(applicationDict)
        } catch {
            print("error")
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let pushups = applicationContext["pushups"] as! String
        let squats = applicationContext["squats"] as! String
        let crunches = applicationContext["crunches"] as! String
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            self.ref.observeAuthEventWithBlock({ authData in
                if authData != nil {
                    // user authenticated
                    var ref = "https://motionapp.firebaseio.com/Users/" + (authData.uid) + "/goals"
                    var something = Firebase(url: ref)
                    something.childByAppendingPath("workout").setValue(["pushups": self.pickerData[0][self.position[0]],"squats": self.pickerData[1][self.position[1]],"crunches":  self.pickerData[2][self.position[2]]])
                    self.send([self.pickerData[0][self.position[0]],self.pickerData[1][self.position[1]],self.pickerData[2][self.position[2]]])
                } else {
                    // No user is signed in
                }
            })
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
