import UIKit
import Firebase

class HealthDataViewController: UIViewController {

    @IBOutlet weak var sex: UISwitch!
    
    var ref = Firebase(url: "https://motionapp.firebaseio.com/")
    
    @IBOutlet weak var height: UITextField!
    
    @IBOutlet weak var weight: UITextField!
    
    @IBOutlet weak var Age: UITextField!

    @IBAction func submitData(sender: AnyObject) {
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                
                var ref = "https://motionapp.firebaseio.com/Users/" + (authData.uid) + "/"
                var something = Firebase(url: ref)
                
                var sex = "unknown"
                
                if(self.sex.on){
                    sex = "female"
                }else{
                    sex = "male"
                }
                
                something.childByAppendingPath("userData").setValue(["Sex": sex,"height": String(self.height.text!), "weight": String(self.weight.text!), "age": String(self.Age.text!)])
                
                self.performSegueWithIdentifier("sendUserData", sender:nil);
            } else {
                // No user is signed in
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
