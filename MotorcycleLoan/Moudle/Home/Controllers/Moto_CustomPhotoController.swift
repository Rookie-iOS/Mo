//
//  Moto_CustomPhotoController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD
import AVFoundation

class Moto_CustomPhotoController: Moto_ViewController {
    
    var cardType = "UMID"
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var centerX: NSLayoutConstraint!
    
    private var session: AVCaptureSession!
    private var input: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    private var _callback:((UIImage)->Void)? = nil
    private var previewLayer: AVCaptureVideoPreviewLayer!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configure()
    }
    
    private func configure() {
        
        view.backgroundColor = .black
        centerX.constant = 0.5*Moto_Const.width - 26
        backBtn.transform = CGAffineTransform(rotationAngle: .pi/2)
        tipsText.transform = CGAffineTransform(rotationAngle: .pi/2)
        tipsText.text = "Please put your \(cardType) photo into the box"
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let _input = try? AVCaptureDeviceInput(device: device) else { return }
        input = _input
        
        photoOutput = AVCapturePhotoOutput()
        session = AVCaptureSession()
        
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        layerView.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.cornerRadius = 10
        if #available(iOS 17.0, *) {
            if previewLayer.connection?.isVideoRotationAngleSupported(Double.pi/2) ?? false {
                previewLayer.connection?.videoRotationAngle = Double.pi/2
            }
        } else {
            previewLayer.connection?.videoOrientation = .portrait
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            session.startRunning()
        }
    }
    
    @IBAction private func takePicAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            navigationController?.popViewController(animated: true)
        case 200:
            generatePic()
        default:
            break
        }
    }
    
    private func generatePic() {
        
        guard let connection = photoOutput.connection(with: .video) else {
            WisdomHUD.showTextCenter(text: "Take photo failed!")
            return
        }
        
        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 0
            }
        } else {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        var setting = AVCapturePhotoSettings()
        if photoOutput.availablePhotoCodecTypes .contains(where: { $0 == .jpeg }) {
            let dict = [AVVideoCodecKey: AVVideoCodecType.jpeg]
            setting = AVCapturePhotoSettings(format: dict)
        }
        
        if setting.isHighResolutionPhotoEnabled {
            setting.isHighResolutionPhotoEnabled = true
        }
        
        setting.photoQualityPrioritization = .balanced
        photoOutput.capturePhoto(with: setting, delegate: self)
    }
    
    // TODO: 图片旋转
    private func rotate(_ image: UIImage, _ radians: CGFloat) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            image.draw(in: CGRect(x: -image.size.width / 2.0,
                                  y: -image.size.height / 2.0,
                                  width: image.size.width,
                                  height: image.size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage
        }
        return nil
    }
    
    func takePic(_ callback:@escaping ((_ image: UIImage) -> Void)) {
        _callback = callback
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layer = previewLayer else { return }
        layer.frame = self.layerView.bounds;
    }
    
}

extension Moto_CustomPhotoController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        session.stopRunning()
        guard let data = photo.fileDataRepresentation() else { return }
        guard let originImg = UIImage(data: data) else { return }
        var newImg: UIImage!
        if #available(iOS 17, *) {
            newImg = originImg
        }else {
            guard let _new = rotate(originImg, -CGFloat.pi/2) else { return }
            newImg = _new
        }
        navigationController?.popViewController(animated: true)
        guard let c = _callback else { return }
        c(newImg)
    }
}
