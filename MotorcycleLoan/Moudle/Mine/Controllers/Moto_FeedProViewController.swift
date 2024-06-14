//
//  Moto_FeedProViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit
import WisdomHUD

class Moto_FeedProViewController: Moto_ViewController {
    
    private var uploadImg: UIImage?
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inputTextBgView: UIView!
    @IBOutlet weak var textInputText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        uploadBtn.layer.cornerRadius = 8
        uploadBtn.layer.masksToBounds = true
        
        inputTextBgView.layer.cornerRadius = 8
        inputTextBgView.layer.borderWidth = 0.5
        inputTextBgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(textInputChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textInputChange(_ not: Notification) {
        
        guard let input = not.object as? UITextView else { return }
        guard let text = input.text else { return }
        placeHolder.isHidden = !text.isEmpty
    }
    
    private func openImagePicker() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            openImagePicker()
        case 200:
            guard let text = textInputText.text else { return }
            if text.isEmpty {
                WisdomHUD.showTextCenter(text: "The content cannot be empty").setFocusing()
                return
            }
            var params = [
                "type": "1",
                "motocontent_data": text,
                "moto_phone": Moto_Utils.userInfo()?.phone ?? "",
            ]
            if let img = uploadImg {
                guard let imageData = img.jpegData(compressionQuality: 0.1) else { return }
                params["moto_img"] = imageData.base64EncodedString()
            }
            WisdomHUD.showLoading(text: "")
            Moto_Networking.request(path: Moto_Apis.Moto_api_feedback, method: .post, params: params) { [weak self] data in
                WisdomHUD.dismiss()
                guard let self = self else { return }
                guard let jsonData = data else { return }
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
                if model.code == 200 {
                    WisdomHUD.showTextCenter(text: "Submit successfully").setFocusing()
                    navigationController?.popViewController(animated: true)
                }else {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            }
        default:
            break
        }
    }
}

extension Moto_FeedProViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let img = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true)
        uploadImg = img
        uploadBtn.setImage(img, for: .normal)
    }
}
