//
//  DetailWebViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/28.
//

import UIKit
import WebKit
import RealmSwift
import Alamofire

class DetailWebViewController: PullUpController {
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var webView: WKWebView!
    enum InitialState {
       case contracted
       case expanded
   }
   private var safeAreaAdditionalOffset: CGFloat {
       hasSafeArea ? 20 : 0
   }
   var initialState: InitialState = .contracted
       
    var initialPointOffset: CGFloat {
          switch initialState {
          case .contracted:
              return (preview.frame.height) + safeAreaAdditionalOffset
          case .expanded:
              return pullUpControllerPreferredSize.height
          }
      }
    

    
    public var portraitSize: CGSize = .zero
    public var landscapeFrame: CGRect = .zero

    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
       
       view.layer.cornerRadius = 30
   }
    
    var p_no : Int?
    var json : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: view.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)
        // Do any additional setup after loading the view.
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.configuration.userContentController.add(self, name:"callbackHandler")
        
        let url = Bundle.main.url(forResource: "druginfo", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        
//        webView.scales
        webView.load(request)
        webView.scrollView.attach(to: self)
//        webView.scrollView.contentOffset.y
        loadData()
        
        webView.isUserInteractionEnabled = false
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
    
    fileprivate func loadData(){
        if let p_no = p_no {
            let realm = try! Realm()
            let drug = realm.objects(Drug.self).filter("p_no == \(p_no)").first
            
            
            let url = URL(string: drug!.img)

//            DispatchQueue.global().async {
//                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                DispatchQueue.main.async {
//    //                cell.previewImg.image = UIImage(data: data!)
//
//                    UIView.transition(with: self.headerImageView,
//                                          duration: 0.3,
//                                          options: .transitionCrossDissolve,
//                                          animations: { self.headerImageView.image = UIImage(data: data!) },
//                                          completion: nil)
//
//
//                }
//            }
//            p_no
            json = drug?.jsonRepresentatio()
            
//            get_detail(p_no: String(p_no))
            getdetail2(item_seq: String(p_no))
//
        }
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

          
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func pullUpControllerWillMove(to stickyPoint: CGFloat) {
          print("will move to \(stickyPoint)")
      }
      
      override func pullUpControllerDidMove(to stickyPoint: CGFloat) {
          print("did move to \(stickyPoint)")

        print("pullUpControllerPreferredSize.height : \(pullUpControllerPreferredSize.height)")
        
        if stickyPoint == pullUpControllerPreferredSize.height{
            webView.isUserInteractionEnabled = true
        }else{
            webView.isUserInteractionEnabled = false
        }
      }
      
      override func pullUpControllerDidDrag(to point: CGFloat) {
          print("did drag to \(point)")
        
        
      }
      
  
  
  override var pullUpControllerPreferredSize: CGSize {
      return portraitSize
  }
  
  override var pullUpControllerPreferredLandscapeFrame: CGRect {
      return landscapeFrame
  }
  
  override var pullUpControllerMiddleStickyPoints: [CGFloat] {
      switch initialState {
      case .contracted:
          return [preview.frame.maxY]
      case .expanded:
          return [preview.frame.maxY + safeAreaAdditionalOffset, preview.frame.maxY]
      }
  }
  override var pullUpControllerBounceOffset: CGFloat {
      return 20
  }
    
    override func pullUpControllerAnimate(action: PullUpController.Action,
                                           withDuration duration: TimeInterval,
                                           animations: @escaping () -> Void,
                                           completion: ((Bool) -> Void)?) {
         switch action {
         case .move:
             UIView.animate(withDuration: 0.3,
                            delay: 0,
                            usingSpringWithDamping: 0.7,
                            initialSpringVelocity: 0,
                            options: .curveEaseInOut,
                            animations: animations,
                            completion: completion)
         default:
             UIView.animate(withDuration: 0.3,
                            animations: animations,
                            completion: completion)
         }
     }
}
extension DetailWebViewController : WKNavigationDelegate{
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
    
    
}
extension DetailWebViewController : WKScriptMessageHandler, WKUIDelegate, UIScrollViewDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("callbackHandler")
        if message.name == "callbackHandler" {
            if message.body as! String == "adjustSize" {
                
                debugPrint("adjustSize")
                
                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    if let h = height{
                        debugPrint("height : \(h)")
                       
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < 0 {
            
//            pullUpControllerCurrentPointOffset = scrollView.contentOffset.y
//            webView.isUserInteractionEnabled = false
//            scrollView.isScrollEnabled = false
//            pullUpControllerCurrentPointOffset = pullUpControllerPreferredSize.height - scrollView.contentOffset.y
        }else{
            
            
//            scrollView.isScrollEnabled = true
//            webView.isUserInteractionEnabled = true
        }
    }
}
