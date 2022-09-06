//
//  ShareViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/18.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var copyContentLabel: UILabel!
    var copyContent:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        if let copyContent = self.copyContent {
            copyContentLabel.text = copyContent
        }
        
    }
    
    
    class func create() -> ShareViewController {
          let detailViewController = ShareViewController(nibName: "ShareViewController", bundle: nil)
        
          return detailViewController
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickMail(_ sender: Any) {
        if let copyContent = self.copyContent {
        }
    }
    @IBAction func onClickKakao(_ sender: Any) {
        if let shareText = self.copyContent {
            var shareObject = [Any]()
            shareObject.append(shareText)
            let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view
//            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        
        
        
   

        
        
        
    }
    @IBAction func onClicpClipboard(_ sender: Any) {
        if let copyContent = self.copyContent {
            UIPasteboard.general.string = copyContent
            
            let alert = UIAlertController(
              title: nil,
              message: "클립보드 복사했습니다.",
              preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                
                self.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true)
        }
        
    }
    @IBAction func onClickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
