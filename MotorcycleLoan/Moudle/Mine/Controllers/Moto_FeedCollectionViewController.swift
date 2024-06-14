//
//  Moto_FeedCollectionViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit
import WisdomHUD

class Moto_FeedCollectionViewController: Moto_ViewController {

    private var uploadImg: UIImage?
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var contentText: UILabel!
    @IBOutlet weak var inputText: UITextView!
    @IBOutlet weak var inputTextBgView: UIView!
    @IBOutlet weak var topSelectBgView: UIView!
    @IBOutlet weak var placeholder: UITextField!
    @IBOutlet weak var textPlaceHolder: UILabel!
    @IBOutlet weak var topSelectBgHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topSelectBgView.layer.cornerRadius = 8
                topSelectBgView.layer.borderWidth = 0.5
                topSelectBgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
                
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
           textPlaceHolder.isHidden = !text.isEmpty
       }
       
       private func bindText(_ list: [String]) {
           
           contentText.isHidden = list.isEmpty
           placeholder.isHidden = !list.isEmpty
           if list.isEmpty {
               contentText.text = ""
               topSelectBgHeight.constant = 44
           }else {
               contentText.text = list.joined(separator: ",")
               let size = contentText.sizeThatFits(CGSize(width: Moto_Const.width - 20 - 36, height: CGFLOAT_MAX))
               let height = size.height > 18 ? 44 + size.height - 18 : 44
               topSelectBgHeight.constant = height
           }
       }
       
       @IBAction func selectQuestionAction(_ sender: UITapGestureRecognizer) {
           
           guard let text = contentText.text else { return }
           guard let selectView = R.nib.moto_FeedSelectView.firstView(withOwner: nil) else { return }
           let titles = ["Unprofessional collection", "Repayment is not timely", "Humiliation/threat", "Unable to repay automatically", "Other"]
           selectView.show(text ,titles) { [weak self] list in
               guard let self = self else { return }
               bindText(list)
           }
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

               guard let text = contentText.text else { return }
               guard let content = inputText.text else { return }
               if text.isEmpty {
                   WisdomHUD.showTextCenter(text: "Please select a question type").setFocusing()
                   return
               }
               if content.isEmpty {
                   WisdomHUD.showTextCenter(text: "The content cannot be empty").setFocusing()
                   return
               }
               var params = [
                   "type": "2",
                   "moto_opinion_type": text,
                   "motocontent_data": content,
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

extension Moto_FeedCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true)
        uploadImg = img
        uploadBtn.setImage(img, for: .normal)
    }
}
