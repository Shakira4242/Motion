import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    let ref = Firebase(url: "https://motionapp.firebaseio.com/")
    let facebookLogin = FBSDKLoginManager()
    
    @IBAction func login(sender: AnyObject) {
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: nil, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                self.ref.authWithOAuthProvider("facebook", token: accessToken,withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(authData)")
                        print("hello")
                        print(authData.providerData["displayName"]!)
                        print(authData.providerData["profileImageURL"]!)
                        
                        let newUser = [
                            "provider": authData.provider,
                            "displayName": authData.providerData["displayName"] as? NSString as? String,
                            "profileImage": authData.providerData["profileImageURL"] as? String
                        ]
                        
                        self.ref.childByAppendingPath("Users").childByAppendingPath(authData.uid).setValue(newUser)
                        
                        self.performSegueWithIdentifier("loginToEnterData", sender:nil);
                    }
                    
                })
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
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



