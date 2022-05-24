//
//  TermsViewController.swift
//  
//
//  Created by Pedro on 2017-07-03.
//
//

import UIKit

class PrivacyViewController: UIViewController {

    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
    let htmlCode = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadHtmlFile()
        
    }

    func loadHtmlFile() {
        let url = Bundle.main.url(forResource: "privacypolicy", withExtension:"htm")
        let request = NSURLRequest.init(url: url!)
        self.webView.loadRequest(request as URLRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
