//
//  DetailViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/29.
//

import UIKit
import WebKit
import RealmSwift
import Alamofire
import Hero
class DetailViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var id : Int?
    var p_no : Int?
    var json : String?
    var getImg: UIImage?
    var p_name : String?
    
    var img_hero_id : String?
    var name_hero_id : String?
    class func create() -> DetailViewController {
          let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
          return detailViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webview.scrollView.delegate = self
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.configuration.userContentController.add(self, name:"callbackHandler")
        
        let url = Bundle.main.url(forResource: "druginfo", withExtension: "html")!
        
        
        
        webview.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        
//        webView.scales
        webview.load(request)
       
        if let p_name = p_name{
            nameLabel.text = p_name
        }
        
        if let img = getImg{
            imageView.image = img
        }
        
        if let img_hero_id = img_hero_id {
            imageView.hero.id = img_hero_id
        }
        
        if let name_hero_id = name_hero_id{
            nameLabel.hero.id = name_hero_id
        }
        loadData()
    view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))))
        
//        navigationController?.interactivePopGestureRecognizer?.delegate = nil

    }
    @objc func handlePan(gr: UIPanGestureRecognizer) {
      let translation = gr.translation(in: view)
      switch gr.state {
      case .began:
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
      case .changed:
        Hero.shared.update(translation.y / view.bounds.height)
      default:
        let velocity = gr.velocity(in: view)
        if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
          Hero.shared.finish()
        } else {
          Hero.shared.cancel()
        }
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
    var interactor:Interactor? = nil
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
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
    
    @IBAction func onClickSavedList(_ sender: Any) {
        presentSavedListViewConroller()
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        if let name = p_name {
            presentShareViewConroller(copyString: name)
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
                    
                    UIView.transition(with: self.imageView,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: { self.imageView.image = UIImage(data: data!) },
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
            
            webview.evaluateJavaScript("initDataWithExtendXml('\(json)','\(base64Encoded)')", completionHandler: {
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
extension DetailViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let containerHeight = topContainer.bounds.height
        
        if scrollView.contentOffset.y > 0 {
                   
           if scrollView.contentOffset.y < containerHeight {
               topConstraint.constant = -scrollView.contentOffset.y
           } else {
               topConstraint.constant = -containerHeight
           }
           
       } else {
           topConstraint.constant = 0
       }
    }
}
extension DetailViewController : WKNavigationDelegate{
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
    
    
    self.webview.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
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
extension DetailViewController : WKScriptMessageHandler, WKUIDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("callbackHandler")
        if message.name == "callbackHandler" {
            if message.body as! String == "adjustSize" {
                
                debugPrint("adjustSize")
                
                self.webview.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    if let h = height{
                        debugPrint("height : \(h)")
                        DispatchQueue.main.asyncAfter(deadline: .now() ) {
//                            self.webView.frame.size.height = 1
//                            self.heightConstraint.constant = 1
//                            self.webView.frame.size.height = h as! CGFloat
//                            self.heightConstraint.constant = h as! CGFloat
//                            self.scrollView.contentSize.height = h as! CGFloat + 300
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
class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}
extension DetailViewController: DrawerPresentationControllerDelegate {
    func drawerMovedTo(position: DraweSnapPoint) {
        
    }
    
    func presentShareViewConroller(copyString:String) {
        let viewController = ShareViewController.create()
        viewController.copyContent = copyString
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            self.present(viewController, animated: true)
        }
    
    func presentSavedListViewConroller() {
        let viewController = SavedListViewController.create()
        viewController.rel_id = id
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            self.present(viewController, animated: true)
        }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController =  DrawerPresentationController(presentedViewController: presented, presenting: presenting, blurEffectStyle: .regular)
        presentationController.cornerRadius = 20
        presentationController.roundedCorners = [.topLeft, .topRight]
        presentationController.bounce = false
        presentationController.topGap = 200
        
        return presentationController
    }
}
