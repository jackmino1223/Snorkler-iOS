

import UIKit
import Alamofire
import SwiftyJSON

//private enum sexState {
//    var unknown  = 0
//    var male = 2
//}


class PreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var bothButton: UIButton!
    var sexIndex: Int = 0
    
    var distanceData = ["5 Miles", "10 Miles", "20 Miles", "50 Miles"]
    var pickerData: NSArray = []
  
    
    @IBOutlet weak var srollview: UIScrollView!
    @IBOutlet weak var tagsView: JCTagListView!
    private var interestsArray:Array<Interest> = []
    private var selectedInterestsArray:Array<Interest> = []
    private var layout: JCCollectionViewTagFlowLayout!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        distanceTextField.delegate = self
        self.pickerView.delegate = self
        
        [maleButton,femaleButton, bothButton].forEach {
            $0?.setImage(#imageLiteral(resourceName: "selected"), for: .selected)
            $0?.setImage(#imageLiteral(resourceName: "unselected"), for: .normal)
            $0?.addTarget(self, action: #selector(didCheckOption(_:)), for: .touchUpInside)
        }
        
        getTrendingInterests()
        layout = JCCollectionViewTagFlowLayout.init()
        
    }

    func showPicker(index: Int){

        self.pickerData = distanceData as NSArray
        self.pickerView.isHidden = false
        self.pickerView.reloadAllComponents()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData.object(at: row) as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        self.distanceTextField.text = self.pickerData.object(at: row) as? String
        self.pickerView.isHidden = true
        
    }
    
    func didCheckOption(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
        }
        if(sender == maleButton && sender.isSelected) {
            sexIndex = 1
            femaleButton.isSelected = false
            bothButton.isSelected = false
        }else if(sender == femaleButton && sender.isSelected) {
            sexIndex = 2
            maleButton.isSelected = false
            bothButton.isSelected = false
        }else if(sender == bothButton && sender.isSelected) {
            sexIndex = 3
            femaleButton.isSelected = false
            maleButton.isSelected = false
        }
    }
    
    private func getTrendingInterests() {
        showLoading()
        
        Alamofire.request("http://54.67.89.86/Snorkler/api/twitter-trends/?zipcode=" + UserDefaults.standard.string(forKey: "zipcode")!).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let tArray = swiftyJsonVar.array;
                let interests:[JSON] = (tArray?.first!["trends"].arrayValue)!
                
                interests.forEach { itemJSON in
                    
                    var newStr: String = itemJSON["query"].stringValue
                    
                    for i in 22 ... 30{
                        newStr = newStr.replacingOccurrences(of: "%" + String(i), with: "", options: .literal, range: nil)
                    }
                    newStr = newStr.replacingOccurrences(of: "+", with: "", options: .literal, range: nil)
                    
                    let item = Interest(interestId: "", interestName: newStr)
                    self.interestsArray.append(item)
                }
                DispatchQueue.main.async {
                    self.setupTags()
                }
                print(swiftyJsonVar.array?.first?["trends"] ?? "")
            }
            self.hideLoading()
            
        }
    }
    
    private func setupTags() {
        tagsView.canSelectTags = true
        tagsView.tagSelectedTextColor = .black
        let tags = interestsArray.map{ $0.interestName }
        tagsView.tags = NSMutableArray(array: tags)
        tagsView.selectedTags = []
        tagsView.tagCornerRadius = 2.0
        tagsView.tagStrokeColor = UIColor(hex:0x1A95D6)
        tagsView.tagTextColor = UIColor(hex:0x1A95D6)
        tagsView.setCompletionBlockWithSelected { index in
            self.selectedInterestsArray.append(self.interestsArray[index])
        }
        
        let height = layout.calculateContentHeight(self.tagsView.tags as! [Any]!)
        self.tagsView.collectionView.reloadData()
        self.srollview.contentSize = CGSize(width: self.srollview.frame.size.width, height: height + 150)
        self.tagViewHeight.constant = height + 150
        
        //        self.tagsView.frame = CGRect(x: 0, y: 0, width: self.srollview.frame.size.width, height: height + 130)
    }
    
    @IBAction func onBothButton(_ sender: Any) {
    }
    
    @IBAction func onFemaleButton(_ sender: Any) {
    }
    
    @IBAction func onMaleButton(_ sender: Any) {
    }
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension PreferencesViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == distanceTextField {
            showPicker(index: 1)
            return false
        }
        
        return true

        
    }
}
