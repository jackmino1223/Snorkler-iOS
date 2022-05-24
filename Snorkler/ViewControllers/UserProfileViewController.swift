//
//  UserProfileViewController.swift
//  Snorkler
//
//  Created by ナム Nam Nguyen on 5/12/17.
//  Copyright © 2017 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import SwiftLocation
import AlamofireImage
import ImagePicker
import SDWebImage

extension UIImageView{
    func blurImage() {
        if AppSession.shared.backgroundImage != nil {
            let blurImageView = UIImageView(frame: self.frame)
            blurImageView.image = AppSession.shared.backgroundImage
            blurImageView.sizeToFit()
            blurImageView.contentMode = .scaleAspectFit
            blurImageView.center = self.center
            self.addSubview(blurImageView)
            return
        }
        let layer = self.layer
        UIGraphicsBeginImageContext(self.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndImageContext()
        
        let blurRadius = 5
        let ciimage: CIImage = CIImage(image: self.image!)!
        
        // Added "CIAffineClamp" filter
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setDefaults()
        affineClampFilter.setValue(ciimage, forKey: kCIInputImageKey)
        let resultClamp = affineClampFilter.value(forKey: kCIOutputImageKey)
        
        // resultClamp is used as input for "CIGaussianBlur" filter
        let filter: CIFilter = CIFilter(name:"CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(resultClamp, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        
        let ciContext = CIContext(options: nil)
        let result = filter.value(forKey: kCIOutputImageKey) as! CIImage!
        let cgImage = ciContext.createCGImage(result!, from: ciimage.extent) // changed to ciiimage.extend
        
        let finalImage = UIImage(cgImage: cgImage!)
        
        if AppSession.shared.backgroundImage == nil {
           AppSession.shared.backgroundImage = finalImage
        }
        
        let blurImageView = UIImageView(frame: self.frame)
        blurImageView.image = finalImage
        blurImageView.sizeToFit()
        blurImageView.contentMode = .scaleAspectFit
        blurImageView.center = self.center
        
        self.addSubview(blurImageView)
    }
}

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    


    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var alertController: UIAlertController!
    var imageToUpload: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            if self.revealViewController() != nil {
                menuButton.target = self.revealViewController()
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            guard let userinfo = AppSession.shared.userInfo else { return }
            nameLabel.text = userinfo.firstname + " " + userinfo.lastname
        
            AppSession.beginSession()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (UserDefaults.standard.bool(forKey: "isLogedin")){
            
        self.locationLabel.text = AppSession.shared.currentLocation ?? "Not found"
        loadLocation()
            
        /*
        if let dpImage = AppSession.shared.userInfo?.dp {
            avatarImage.af_setImage(withURL: URL(string:dpImage)!)
            backgroundImage.af_setImage(withURL: URL(string:dpImage)!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue(label: "com.snorkler.loading_image"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: { (dataResponse) in
//                self.backgroundImage.blurImage()
            })
        } else {
            guard let image = AppSession.shared.avatarImage else { return }
            avatarImage.image = image
            backgroundImage.image = image
//            backgroundImage.blurImage()
        }
        */
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!UserDefaults.standard.bool(forKey: "isLogedin")){
            self.navigationController?.parent?.performSegue(withIdentifier: "toLogin", sender: self)
        }
    }

    
    private func loadLocation() {
        DispatchQueue(label: "com.snorkler.locationupdate").async {
            Location.getLocation(accuracy: .city, frequency: .oneShot, success: { (_, location) in
                Location.getPlacemark(forLocation: location, success: { placemarks in
                    if let place = placemarks.first {
                        if let addressDict = place.addressDictionary {
                            let district:String = addressDict["SubAdministrativeArea"] as? String ?? ""
                            let city:String = addressDict["State"] as? String ?? ""
//                            let country:String = addressDict["Country"] as? String ?? ""
                            let address = ([district, city] as [String]).joined(separator: ", ")
//                            let address = ([district, city, country] as [String]).joined(separator: ", ")
                            print(address)
                            AppSession.shared.currentLocation = address
                            
                            DispatchQueue.main.async {
                                self.locationLabel.text = address
                                self.locationLabel.sizeToFit()
                            }
                        }
                    }
                }) { error in
                    print("Cannot retrive placemark due to an error \(error)")
                }
            }) { (request, last, error) in
                request.cancel() // stop continous location monitoring on error
                print("Location monitoring failed due to an error \(error)")
            }
        }
    }
    
    @IBAction func onRetakePicture(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: nil, message: "Please choose your profile picture.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take from camera", style: .default, handler: showCamera)
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default, handler: showLibrary)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        openImagePicker()
        
    }
    
    private func showCamera(action: UIAlertAction) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    private func showLibrary(action: UIAlertAction) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    private func canAlert(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
    }
    
    private func openImagePicker() {
        
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageToUpload = pickedImage
            avatarImage.image = pickedImage
            backgroundImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /*
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else { return }
        imageToUpload = image
        imagePicker.dismiss(animated: true, completion: nil)
        avatarImage.image = image
        backgroundImage.image = image
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    */
 
    @IBAction func exploreDidTouch(_ sender: Any) {
        let videoViewController = VideoChatViewController(nibName: "VideoChatViewController", bundle: nil)
        self.present(videoViewController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
