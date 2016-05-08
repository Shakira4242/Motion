import UIKit
import Firebase
import WatchConnectivity
import WatchKit

class DashboardViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    
    var session : WCSession!
    
    var ref = Firebase(url: "https://motionapp.firebaseio.com/")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var color = UIColor(netHex:0x11293a)
        self.view.backgroundColor = color
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
                
        // Do any additional setup after loading the view.
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                var ref = "https://motionapp.firebaseio.com/Users/" + (authData.uid)
                var something = Firebase(url: ref)
                something.observeEventType(.Value, withBlock: { snapshot in
                    print(snapshot.value.objectForKey("profileImage")!)
                    let url = NSURL(string: snapshot.value.objectForKey("profileImage")! as! String)
                    let name = snapshot.value.objectForKey("displayName") as! String
                    self.name.text = String(UTF8String: name)!
                    let data = NSData(contentsOfURL: url!)
                    self.profile.image = UIImage(data:data!)
                    }, withCancelBlock: {
                        error in
                        print(error.description)
                })
            } else {
                // No user is signed in
            }
        })
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
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let pushups = applicationContext["pushups"] as! String
        let squats = applicationContext["squats"] as! String
        let crunches = applicationContext["crunches"] as! String
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            print(pushups)
            print(squats)
            print(crunches)
        }
    }

}