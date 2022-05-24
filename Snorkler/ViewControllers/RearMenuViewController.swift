//
//  RearMenuViewController.swift
//  Snorkler
//
//  Created by ナム Nam Nguyen on 5/20/17.
//  Copyright © 2017 Medigarage Studios LTD. All rights reserved.
//

import UIKit

class RearMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableMenu: UITableView!
    internal let MENUS:[String] = ["Home", "My Profile", "Preferences", "Terms", "Privacy Policy"]
    internal let ICONS:[UIImage] = [#imageLiteral(resourceName: "selectCamera"), #imageLiteral(resourceName: "name"), #imageLiteral(resourceName: "selectMessage"), #imageLiteral(resourceName: "selectMessage"), #imageLiteral(resourceName: "selectMessage")]
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userinfo = AppSession.shared.userInfo else { return }
        nameLabel.text = userinfo.firstname + " " + userinfo.lastname
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.locationLabel.text = AppSession.shared.currentLocation ?? "Not found"
        guard let image = AppSession.shared.avatarImage else { return }
        avatarImage.image = image
        backgroundImage.image = image
        // backgroundImage.blurImage()
        tableMenu.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MENUS.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "menu_cell")
            cell!.backgroundColor = .clear
            cell!.selectionStyle = .none
            cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell!.textLabel?.textColor = .white
        }
        cell!.textLabel?.text = MENUS[indexPath.row]
        cell!.imageView?.image = ICONS[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let revealController = self.revealViewController() else { return }
        switch indexPath.row {
        case 0:
            guard let navi_conversation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navi_video") as? UINavigationController else { return }
            revealController.pushFrontViewController(navi_conversation, animated: true)
            break
        case 1:
            guard let navi_conversation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navi_video") as? UINavigationController else { return }
            revealController.pushFrontViewController(navi_conversation, animated: true)
            break
        
        case 2:
            guard let navi_conversation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreferencesViewController") as? UINavigationController else { return }
            revealController.pushFrontViewController(navi_conversation, animated: true)
            break
 
        case 3:
            guard let navi_conversation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController") as? UINavigationController else { return }
            revealController.pushFrontViewController(navi_conversation, animated: true)
            break
        case 4:
            guard let navi_conversation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyViewController") as? UINavigationController else { return }
            revealController.pushFrontViewController(navi_conversation, animated: true)
            break
            
            
        default:
            break
        }
    }
    
    @IBAction func signoutDidTouch(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "isLogedin")
        self.parent?.performSegue(withIdentifier: "toLogin", sender: self)
        
        //        let str = String(describing: vc?.frontViewController.rootview)
//        nav.roo ?.frontViewController.performSegue(withIdentifier: "toLogin", sender: self)
        
    }

}
