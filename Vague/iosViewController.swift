import UIKit
import WatchConnectivity
import CloudKit

class iosViewController: UIViewController, iCloudUpdateDelegate, WCSessionDelegate {
    @IBOutlet weak var received: UILabel!
    
    var iCloud = iCloudManager()
    
    var session : WCSession!

    func iCloudUpdated() {
        let updatedCount = iCloud.getiCloudData("count")
        self.received.text = updatedCount
    }
    
    func setCountInIcloud(value: String) {
        iCloud.setiCloudData("count", values: value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        iCloudUpdated()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let emoji = applicationContext["count"] as! String
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            self.received.text = emoji
            self.setCountInIcloud(emoji)
        }
    }
}