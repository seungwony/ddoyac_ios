//
//  DrugDetailViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/21.
//

import UIKit
import WebKit
import RealmSwift
import Alamofire

class MyWebView : WKWebView {
    required init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        configuration.userContentController = controller;
        super.init(frame: CGRect.zero, configuration: configuration)
    }
}
class DrugDetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerContainer: UIView!
    
    var p_no : Int?
    var json : String?
    class func create() -> DrugDetailViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! DrugDetailViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name:"callbackHandler")
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
//        scrollView.translatesAutoresizingMaskIntoConstraints = true
//        loadWebsite()
//        let configuration = WKWebViewConfiguration()
//        let controller = WKUserContentController()
//        configuration.userContentController = controller
//        webView.configuration = configuration
//

        
        
        let url = Bundle.main.url(forResource: "druginfo", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        
//        webView.scales
        webView.load(request)
       
        
        loadData()
        
    }
    
    fileprivate func getdetail2(item_seq:String){
        AF.request("http://apis.data.go.kr/1471057/MdcinPrductPrmisnInfoService1/getMdcinPrductItem?ServiceKey=SxFlIFuuam1GbQpirOoR%2FSkLZRJN9Qwf4a3%2FI3QkmE%2Fij6u07joiJ6DgZmToQElFA32HgCgMTZ%2BEaayfFLXthg%3D%3D",method:.get, parameters:["item_seq":item_seq], encoding: URLEncoding.default,headers:ApiManager.getHeader()).responseString { response in
//            print(" - API url: \(String(describing: response.request!))")
                    switch response.result {
                    case .success(let value):
                        
//                        print(response.debugDescription)
                        if let xml = String(data: response.data!, encoding: .utf8){
                            self.loadXml(xml: xml )
                        }
                        
                        let xmlStr = value.data(using: String.Encoding.utf8, allowLossyConversion: false)
                        
                        
//                        debugPrint(v)
                        
                        //use myOutput class for your needs
                    break
                    case .failure( _): break
                        
                    }
                }
    }
    
    
//    fileprivate func loadXml(xml:String){
//        let html = "javascript:initDataWithExtendXml('"+json+"','"+apiResultXml+"')";
//    }
    
    fileprivate func get_detail(p_no:String){
        AF.request(Router.getDrugDetail(item_seq: p_no))
            .responseString { response in
                switch response.result {
                    
                case .success(let value):
                    debugPrint("get_detail")
//                    debugPrint(value as AnyObject)
                    break
                case .failure(let error):
                    print("error : \(error)")
                }
            }
    

    }
    
    fileprivate func loadData(){
        if let p_no = p_no {
            let realm = try! Realm()
            let drug = realm.objects(Drug.self).filter("p_no == \(p_no)").first
            
            
            let url = URL(string: drug!.img)

            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
    //                cell.previewImg.image = UIImage(data: data!)
                    
                    UIView.transition(with: self.headerImageView,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: { self.headerImageView.image = UIImage(data: data!) },
                                          completion: nil)
                    
                   
                }
            }
//            p_no
            json = drug?.jsonRepresentatio()
            
//            get_detail(p_no: String(p_no))
            getdetail2(item_seq: String(p_no))
//            
        }
    }
    
    private func loadWebsite() {
            guard let url = URL(string: "google.com") else { return }
            
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    
    
    private func loadXml(xml:String){
        guard let json = self.json else {
            return
        }
        
//        debugPrint("json : \(json)")
//        debugPrint("xml : \(xml)")
//        debugPrint("initData('\(json)')")
        
//        debugPrint(loadXml)
        let utf8str = xml.data(using: .utf8)
        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
//            print("Encoded: \(base64Encoded)")
//            let loadXml = "setXml('\(base64Encoded)');"
            
            webView.evaluateJavaScript("initDataWithExtendXml('\(json)','\(base64Encoded)')", completionHandler: {
                     (any, err) -> Void in
                     print(err ?? "no error")
                 })

            
//            webView.evaluateJavaScript(loadXml, completionHandler: {
//                     (any, err) -> Void in
//                     print(err ?? "no error")
//                 })
//            if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
//            .map({ String(data: $0, encoding: .utf8) }) {
//                // Convert back to a string
//                print("Decoded: \(base64Decoded ?? "")")
//            }
        }

        
        
//        webView.evaluateJavaScript("initData('\(json)')", completionHandler: {
//                 (any, err) -> Void in
//                 print(err ?? "no error")
//             })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DrugDetailViewController : WKNavigationDelegate, UIScrollViewDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//       activityIndicator.startAnimating()
   }
   
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//       activityIndicator.stopAnimating()
    
    debugPrint("didFinish")
    
//    let height = webView.scrollView.contentSize.height
    
    
    webView.frame.size.height = 1
//    webView.frame.size.height = height
    
//    self.scrollView.contentSize.height = height + 300
    
    
    self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
//                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
//                    if let h = height{
//                        debugPrint("height : \(h)")
//
//                        self.heightConstraint.constant = h as! CGFloat
//                        self.scrollView.contentSize.height = h as! CGFloat + 300
//                    }
//
//
//                })
            }

            })

   }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0.0 {
            headerHeightConstraint?.constant = 300 - scrollView.contentOffset.y
        } else {
            let parallaxFactor: CGFloat = 0.25
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / 300
            headerTopConstraint?.constant = view.frame.origin.y
            headerHeightConstraint?.constant = 300 - scrollView.contentOffset.y
            headerImageView.layer.contentsRect = CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
        }
    }
}
extension DrugDetailViewController : WKScriptMessageHandler, WKUIDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("callbackHandler")
        if message.name == "callbackHandler" {
            if message.body as! String == "adjustSize" {
                
                debugPrint("adjustSize")
                
                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    if let h = height{
                        debugPrint("height : \(h)")
                        DispatchQueue.main.asyncAfter(deadline: .now() ) {
                            self.webView.frame.size.height = 1
                            self.heightConstraint.constant = 1
                            self.webView.frame.size.height = h as! CGFloat
                            self.heightConstraint.constant = h as! CGFloat
                            self.scrollView.contentSize.height = h as! CGFloat + 300
                        }
                       
                    }
                    
                    
                })
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

          // Create new WKWebView with custom configuration here
//          let configuration = WKWebViewConfiguration()
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
//        let userScript = WKUserScript(source: "redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        controller.addUserScript(userScript)
                
                // js -> native call : name의 값을 지정하여, js에서 webkit.messageHandlers.NAME.postMessage("");와 연동되는 것, userContentController함수에서 처리한다
        controller.add(self, name: "callbackHandler")
                                      
                                      
                                      
        configuration.userContentController = controller
          return WKWebView(frame: webView.frame, configuration: configuration)
      }
}
