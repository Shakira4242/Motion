import Foundation
import CoreMotion
import WatchConnectivity
import Darwin
import WatchKit
import SigmaSwiftStatistics

// All the machine learning is going to be done here
// Once the label is determined the value or the increment is passed to the phone
// Machine learning technique: Right now it is KNN with k=3

class InterfaceController: WKInterfaceController, iCloudUpdateDelegate, WCSessionDelegate {
    
    @IBAction func stopButton() {
        motionManager.stopAccelerometerUpdates()
    }
    
    @IBOutlet var labelA2: WKInterfaceLabel!
    

    @IBOutlet var labelA3: WKInterfaceLabel!
    
    var session : WCSession!
    let motionManager = CMMotionManager()
    var sample:Int = 0
    var array1 = [Double]()
    var counter = 0
    var crunchCounter = 0
    
    var iCloud = iCloudManager()
    
    override init() {
        super.init()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        motionManager.accelerometerUpdateInterval = 0.3
        
    }
    
    override func willActivate() {
        print("getting the contents of featureVector csv file")
        
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
            print("Still working")
        }
        
        print("was able to append to dataset")
        
        if motionManager.accelerometerAvailable {
            let handler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.sample += 1
                self.array1.append(Double(data!.acceleration.y))
                print(Double(data!.acceleration.y),",",self.sample)
                if(self.sample >= 10 && self.array1.count > 10){
                    print(Sigma.average(self.array1)!,",",Sigma.median(self.array1)!,",",Sigma.max(self.array1)!,",",Sigma.min(self.array1)!,",",Sigma.max(self.array1)!-Sigma.min(self.array1)!,",",Sigma.standardDeviationSample(self.array1)!,",",Sigma.varianceSample(self.array1)!,",",1)
                    if(self.KNN([Sigma.average(self.array1)!,Sigma.median(self.array1)!,Sigma.max(self.array1)!,Sigma.min(self.array1)!,Sigma.max(self.array1)!-Sigma.min(self.array1)!,Sigma.standardDeviationSample(self.array1)!,Sigma.varianceSample(self.array1)!],dataSet: dataSet,labels: labels,k: 19) == 1){
                        sleep(1)
                        self.counter += 1
                        self.send(String(self.counter))
                        self.array1 = []
                        self.labelA2.setText(String(self.counter))
                    }else{
                        self.array1.removeFirst()
                    }
                }
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }else {
            labelA2.setText("not available")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        motionManager.stopAccelerometerUpdates()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
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
        
        print(classCount)

        if(classCount["1"]>=18) {
            return 1
        }else{
            return 0
        }
    }
    
    func iCloudUpdated() {
        // TODO get data I care agout
        let updatedCount = iCloud.getiCloudData("count")
    }
    
    func setCountInIcloud(value: String!) {
        iCloud.setiCloudData("count",values: value)
    }

    func send(count: String) {
        let applicationDict = ["count":count]
        do {
            try session.updateApplicationContext(applicationDict)
        } catch {
            print("error")
        }
    }
    

}

