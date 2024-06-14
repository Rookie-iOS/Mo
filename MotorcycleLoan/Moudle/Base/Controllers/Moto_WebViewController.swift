//
//  Moto_WebViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/6/24.
//

import UIKit
import WebKit
import WisdomHUD

class Moto_WebViewController: Moto_ViewController {
    
    var fromRepryment = 0
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    private var _bottomText = ""
    private var bottomBtnClick:(()->Void)? = nil
    private lazy var webView: WKWebView = {
        let preference = WKPreferences() //偏好
        preference.minimumFontSize = 15
        preference.javaScriptCanOpenWindowsAutomatically = true
        
        
        let config = WKWebViewConfiguration()
        config.preferences = preference
        config.userContentController = WKUserContentController()
        
        let web = WKWebView(frame: .zero, configuration: config)
        web.backgroundColor = .clear
        web.layer.cornerRadius = 20
        web.layer.masksToBounds = true
        if #available(iOS 16.4, *) {
            web.isInspectable = true //是否可在Web检查器中检查。
        }
        return web
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        webView.navigationDelegate = self
        containerView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        
        // bottom button
        if !_bottomText.isEmpty {
            bottomViewHeight.constant = 64
            bottomView.isHidden = false
            bottomBtn.setTitle(_bottomText, for: .normal)
        }
    }
    
    @IBAction func btnClick() {
        
        navigationController?.popViewController(animated: true)
        guard let click = bottomBtnClick else { return }
        click()
    }
    
    func loadUrlString(_ urlString: String, _ bottomText: String? = nil, _ andClick:(()->Void)? = nil) {
        
        bottomBtnClick = andClick
        _bottomText = bottomText ?? ""
        var string = urlString
        if !urlString.hasPrefix("http") {
            string = "\(Moto_Networking.host)\(urlString)"
        }
        guard let url = URL(string: string) else { return }
        webView.load(URLRequest(url: url))
        WisdomHUD.showLoading(text: "")
        // 客服交互
        webView.configuration.userContentController.add(self, name: "AppModel")
    }
    
    private func loadSmileToken(_ callback:@escaping((_ token: String)-> Void)) {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_smile_user_id) { data in
            guard let jsonData = data else { WisdomHUD.dismiss(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<String>.self, from: jsonData) else { WisdomHUD.dismiss(); return }
            guard let token = model.data else { WisdomHUD.dismiss(); return }
            callback(token)
        }
    }
    
    func loadSmile() {
        
        loadSmileToken { [weak self] token in
            guard let self = self else { return }
            guard let url = Bundle.main.url(forResource: "smile", withExtension: ".html", subdirectory: "html") else { return }
            let dirUrl = url.deletingLastPathComponent()
            
            let params = ["initParam": "{\"apiHost\": \"https://link.smileapi.io/v1\", \"userToken\":\"\(token)\"}"]
            guard var urlComponents = URLComponents(string: url.absoluteString) else { return }
            urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard let newUrl = urlComponents.url else { return }
            webView.loadFileURL(newUrl, allowingReadAccessTo: dirUrl)
            webView.configuration.userContentController.add(self, name: "onClose")
        }
    }
    
    private func fbkLink() {
        
        Moto_Networking.request(path: Moto_Apis.Moto_api_online_service, method: .post) { [weak self] data in
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<MO_ServiceOnlineModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let link = model.data?.fbu else { return }
                goFbkService(link)
            }
        }
    }
    
    private func goFbkService(_ link: String) {
        
        let webvc = R.storyboard.main.moto_web()!
        webvc.loadUrlString(link)
        navigationController?.pushViewController(webvc, animated: true)
    }
    
    override func backAction() {
        if webView.canGoBack {
            webView.goBack()
        }else {
            if fromRepryment == 1 {
                navigationController?.popToRootViewController(animated: true)
            }else {
                navigationController?.popViewController(animated: true)
                
            }
        }
    }
}

extension Moto_WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        WisdomHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print(error)
        WisdomHUD.dismiss()
    }
}

extension Moto_WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "onClose":
            navigationController?.popViewController(animated: true)
        case "AppModel":
            guard let jsonString = message.body as? String else { return }
            guard let data = jsonString.data(using: .utf8) else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data) else { return }
            guard let root: [String: Any] = json as? [String: Any] else { return }
            guard let type = root["type"] as? Int else { return }
            if type == 0 {
                fbkLink()
            }else {
                guard var tel: String = root["tel"] as? String else { return }
                if tel.hasPrefix("0") {
                    tel = String(tel.suffix(tel.count - 1))
                }
                guard let url = URL(string: "tel:+63\(tel)") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        default:
            break
        }
    }
}

