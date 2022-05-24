//
//  AddInterestViewController.swift
//  Snorkler
//
//  Created by ナム Nam Nguyen on 5/16/17.
//  Copyright © 2017 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import UIColor_Hex
import SwiftyJSON
import Alamofire

struct Interest {
    var interestId: String
    var interestName: String
}

class AddInterestViewController: UIViewController {

    @IBOutlet weak var srollview: UIScrollView!
    @IBOutlet weak var tagsView: JCTagListView!
    @IBOutlet weak var continueButton: UIButton!
    private var interestsArray:Array<Interest> = []
    private var selectedInterestsArray:Array<Interest> = []
    private var layout: JCCollectionViewTagFlowLayout!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout = JCCollectionViewTagFlowLayout.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTrendingInterests()
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
        
        
        /*
        ApiHelper.getTwitterInterests(onsuccess: { result in
            self.hideLoading()
            guard let resultJson = result else { return }
            let interests:[JSON] = resultJson["trends"].arrayValue
            interests.forEach { itemJSON in
                let item = Interest(interestId: "",
                                    interestName: itemJSON["query"].stringValue)
                self.interestsArray.append(item)
            }
            DispatchQueue.main.async {
                self.setupTags()
            }
        }, onfailure: { err in
            self.hideLoading()
        })
         */
        
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
        self.srollview.contentSize = CGSize(width: self.srollview.frame.size.width, height: height + 60)
        self.tagViewHeight.constant = height + 60
        
//        self.tagsView.frame = CGRect(x: 0, y: 0, width: self.srollview.frame.size.width, height: height + 130)
    }
    
    @IBAction func continueButtonDidTouch(_ sender: Any) {
        func onUpdateSuccess() {
            self.performSegue(withIdentifier: "toAddUniversity", sender: self)
        }
        let tags:[String] = selectedInterestsArray.map{ $0.interestId }
        let listIds:String = tags.joined(separator: ",")
        let params:[String:Any] = ["member_id":AppSession.shared.userInfo?.memberId ?? "", "interes_list":listIds]
        showLoading()
        ApiHelper.updateInterests(params: params, onsuccess: { json in
            self.hideLoading()
            onUpdateSuccess()
        }) { (err) in
            print("\(String(describing: err))")
            self.hideLoading()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
