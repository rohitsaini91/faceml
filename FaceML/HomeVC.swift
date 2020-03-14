//
//  HomeVC.swift
//  FaceML
//
//  Created by MACBOOK on 14/03/20.
//  Copyright © 2020 Rohit Saini. All rights reserved.
//

import UIKit
import Vision

class HomeVC: UIViewController {
    
    //OUTLETS
    @IBOutlet weak var observeImageView: UIImageView!
    @IBOutlet weak var tapLbl: UILabel!
    @IBOutlet weak var observeImageViewHeightConstraint: NSLayoutConstraint!
    var selectedImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK:- configUI
    private func configUI(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(gesture)
        
    }
    
    @objc func addImage(){
        uploadImage()
    }
    
    
    //MARK:- clickToAddPicture
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit{
        print("Home screen memory deallocated successfully")
    }

}

extension HomeVC{
    private func detectFaces(){
        //Request
        
        let request = VNDetectFaceRectanglesRequest{(req, err) in
            if let err = err{
                print("request failed to detect faces: \(err)")
            }
            req.results?.forEach({ (face) in
                print(face)
                guard let detectedFaceInfo = face as? VNFaceObservation else{return}
                //Calculating the cropFaceBox Dimension with respect to detectFaceInfo boundingBox
                let scaleHeight = self.view.frame.width / self.selectedImage!.size.width * self.selectedImage!.size.height
                let height = scaleHeight * detectedFaceInfo.boundingBox.height
                let x = self.view.frame.width * detectedFaceInfo.boundingBox.origin.x
                
                //remaining height
                let remainingHeight = (self.view.frame.height - scaleHeight ) / 2
                let y = scaleHeight *  (1 - detectedFaceInfo.boundingBox.origin.y) - height + remainingHeight
                
                let width = self.view.frame.width * detectedFaceInfo.boundingBox.width
              
                let cropFaceBox = UIView()
                cropFaceBox.backgroundColor = .clear
                cropFaceBox.layer.cornerRadius = 10
                cropFaceBox.layer.borderWidth = 3
                cropFaceBox.layer.borderColor = UIColor.red.cgColor
                cropFaceBox.frame = CGRect(x: x, y: y, width: width, height: height)
                self.view.addSubview(cropFaceBox)
                
            })
            
        }
        
        guard let cgImage = selectedImage?.cgImage else{return}
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        //Exception handling
        do{
            try handler.perform([request])
        }
        catch let reqErr{
            print("perform request failed err: \(reqErr)")
        }
       
    }
}

extension HomeVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
     // MARK: - Upload Image
     private func uploadImage()
     {
         let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         
         let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
             print("Cancel")
         }
         actionSheet.addAction(cancelButton)
         
         let cameraButton = UIAlertAction(title: "Take Photo", style: .default)
         { _ in
             print("Camera")
             self.onCaptureImageThroughCamera()
         }
         
         actionSheet.addAction(cameraButton)
         
         let galleryButton = UIAlertAction(title: "Choose Existing Photo", style: .default)
         { _ in
             print("Gallery")
             self.onCaptureImageThroughGallery()
         }
         actionSheet.addAction(galleryButton)
         
         
         actionSheet.popoverPresentationController?.sourceView = self.view
         actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
         actionSheet.popoverPresentationController?.permittedArrowDirections = []
         self.present(actionSheet, animated: true, completion: nil)
     }
     
     @objc open func onCaptureImageThroughCamera()
     {
         if !UIImagePickerController.isSourceTypeAvailable(.camera) {
             //displayToast("Your device has no camera")
             
         }
         else {
             let imgPicker = UIImagePickerController()
             imgPicker.delegate = self
             imgPicker.sourceType = .camera
             present(imgPicker, animated: true, completion: {() -> Void in
             })
         }
     }
     
     @objc open func onCaptureImageThroughGallery()
     {
         self.dismiss(animated: true, completion: nil)
         DispatchQueue.main.async {
             let imgPicker = UIImagePickerController()
             imgPicker.delegate = self
             imgPicker.sourceType = .photoLibrary
             self.present(imgPicker, animated: true, completion: {() -> Void in
             })
         }
     }
     
     
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         picker.dismiss(animated: true, completion: {() -> Void in
         })
         
         let selectedImage: UIImage? = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
         if selectedImage == nil {
             return
         }
         tapLbl.isHidden = true
        
         self.selectedImage = selectedImage
         observeImageView.image = selectedImage
        let scaleHeight = view.frame.width / selectedImage!.size.width * selectedImage!.size.height
        observeImageViewHeightConstraint.constant = scaleHeight
            detectFaces()
         
     }
}

