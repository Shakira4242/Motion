import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        var bgImage = UIImageView(image: UIImage(named: "homepage_background"))
        bgImage.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)
        bgImage.transform = CGAffineTransformMakeScale(screenSize.width / 750, screenSize.height / 1334)
        
        self.view.addSubview(bgImage)
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
