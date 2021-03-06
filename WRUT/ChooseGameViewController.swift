//
//  ChooseGameViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-28.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class ChooseGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.restrictRotation = true
        
        imagePicker.delegate = self
    }
    
    @IBAction func drawingGameChoosen(sender: UIButton) {
        self.appDelegate.drawingInstance = true
        self.appDelegate.gameChoosen = "Drawing"
        self.performSegueWithIdentifier("drawingGame", sender: self)
        appDelegate.connectionManager.updateTimelineCollection("\(appDelegate.connectionManager.myPeerId.displayName) has choosen 'Complete My Drawing'")
    }
    
    @IBAction func drawOverThePicture(sender: UIButton) {
        self.appDelegate.drawingInstance = true
        self.appDelegate.gameChoosen = "Doodle"
        appDelegate.connectionManager.updateTimelineCollection("\(appDelegate.connectionManager.myPeerId.displayName) has choosen 'Doodle my Picture'")
        
        let alert = UIAlertController(title: "", message: "Select Photo Source", preferredStyle: UIAlertControllerStyle.Alert)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            print("Photo Library")
            self.imageSelectorLibrary()
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            print("Camera")
            self.imageSelectorCamera()
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imageSelectorLibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
  
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func imageSelectorCamera() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .Camera
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        //    profileImageView.contentMode = .ScaleAspectFill
       // let editImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let editImage = UIImage(data: originalImage!.lowestQualityJPEGNSData)
        
        print("editImage Size - Original \(originalImage?.size)")
        print("editImage Size - Original \(editImage?.size)")
        
        let size = CGSizeApplyAffineTransform(editImage!.size, CGAffineTransformMakeScale(0.3, 0.3))
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        editImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        print("editImage Size - Original \(scaledImage?.size)")
        
        UIGraphicsEndImageContext()

        self.appDelegate.doodleImage = scaledImage!
        self.appDelegate.gameChoosen = "Doodle"
        self.appDelegate.drawingReceived = GameItem(image: self.appDelegate.doodleImage, owner: appDelegate.connectionManager.myPeerId.displayName)
        
    //    let sendDrawing: NSDictionary = ["drawing": self.appDelegate.doodleImage, "first": "doodle", "sender":appDelegate.connectionManager.myPeerId.displayName]
        
        let sendDrawing: NSDictionary = ["drawing": editImage!, "first": "doodle", "sender":appDelegate.connectionManager.myPeerId.displayName]
        
        self.appDelegate.connectionManager.sendImage(sendDrawing)
        
        self.performSegueWithIdentifier("drawingGame", sender: self)
    }
    
 //   func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {}
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}
