//
//  AddAvatarPhotoViewController.swift
//  Snorkler
//
//  Created by ナム Nam Nguyen on 5/16/17.
//  Copyright © 2017 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker

class AddAvatarPhotoViewController: UIViewController, ImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    var alertController: UIAlertController!
    var imageToUpload: UIImage? = nil
    
    private var percent:Double = 0.0 {
        didSet {
            print("\(self.percent)")
        }
    }
    
    /*
    private var imageToUpload:UIImage? {
        didSet {
            retakeButton.isHidden = (imageToUpload == nil)
            previewImageView.image = imageToUpload
        }
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retakeButton.layer.borderColor = UIColor.colorWithHex(hex: 0x186f78, alpha: 0.5).cgColor
        retakeButton.layer.cornerRadius = 3.0
        retakeButton.layer.backgroundColor = UIColor.white.cgColor
        retakeButton.layer.borderWidth = 1.5
        previewImageView.clipsToBounds = true
        sliderView.isHidden = true
    }
    
    @IBAction func finishButtonDidTouch(_ sender: Any) {
        
        if imageToUpload == nil {
            alert("Please choose your photo")
            return
        }
        
        func onUpdateSuccess() {
            self.performSegue(withIdentifier: "toUserExplorer", sender: self)
        }
        
        showLoading()
        guard let imageData = UIImageJPEGRepresentation(imageToUpload!, 1.0)?.base64EncodedString() else { return }
        guard let member_id = AppSession.shared.userInfo?.memberId else { return }
        AppSession.shared.avatarImage = imageToUpload
        ApiHelper.updateProfilePicture(memberId: member_id,
                                       imageData: imageData,
                                       uploadProgress:{ finishedPercent in
            self.percent = finishedPercent
        }, onsuccess: { (json) in
            self.hideLoading()
            onUpdateSuccess()
        }, onfailure: { errMsg in
            self.hideLoading()
            if let msg = errMsg {
                self.alert(msg)
            }
        })
    }

    @IBAction func captureDidTouch(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func retakeDidTouch(_ sender: Any) {
        showAlert()
    }
    
    private func showAlert(){
        alertController = UIAlertController(title: nil, message: "Please choose your profile picture.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take from camera", style: .default, handler: showCamera)
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default, handler: showLibrary)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: canAlert)
        
        
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
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            previewImageView.image = pickedImage
            imageToUpload = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    
    private func openImagePicker() {
        /*
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.configuration.allowMultiplePhotoSelection = false
        present(imagePickerController, animated: true, completion: nil)
        */
    }
 
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        /*
        guard let image = images.first else { return }
        imageToUpload = image
        imagePicker.dismiss(animated: true, completion: nil)
        */
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    

}
