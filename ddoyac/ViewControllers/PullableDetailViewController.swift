//
//  PullableDetailViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/28.
//

import UIKit
import RealmSwift
import Hero
class PullableDetailViewController: UIViewController {
    class func create() -> PullableDetailViewController {
          let pullableDetailViewController = PullableDetailViewController(nibName: "PullableDetailViewController", bundle: nil)
        
          return pullableDetailViewController
      }
//    @IBOutlet weak var imageView: UIImageView!
    private var originalPullUpControllerViewSize: CGSize = .zero
    var p_no : Int?
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var labelContainerView: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    var nameLabel =  UILabel()
    var p_name : String?
    var imageView = UIImageView()
    private func makeEventTableViewControllerIfNeeded() -> DetailWebViewController {
         let currentPullUpController = children
             .filter({ $0 is DetailWebViewController })
             .first as? DetailWebViewController
        
        let pullUpController = currentPullUpController ??  DetailWebViewController(nibName: "DetailWebViewController", bundle: nil)
        
        
        pullUpController.p_no = p_no

         pullUpController.initialState = .contracted
         if originalPullUpControllerViewSize == .zero {
             originalPullUpControllerViewSize = pullUpController.view.bounds.size
         }

         return pullUpController
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(nameLabel.debugDescription)
        // Do any additional setup after loading the view.
//        self.hero.isEnabled = true
//        self.imageView.hero.navigationAnimationType = .fade
//        self.imageView.hero.id = "preview"
//        self.imageView.hero.modifiers = [.translate(y:100)]
        
        view.addSubview(imageView)
//        if let img = getImage{
//            imageView.image = img
//        }
        view.addSubview(nameLabel)
        if let p_name = p_name{
            nameLabel.text = p_name
        }

        
        self.initImage()
        
        self.progressIndicator.startAnimating()
        self.progressIndicator.hidesWhenStopped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addPullUpController(animated: true)
            self.progressIndicator.stopAnimating()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameLabel.frame = labelContainerView.frame
        imageView.frame = imageContainerView.frame
//        imageView.frame = imageContainerView.frame
        
       
    }
    
    
    private func initImage(){
        if let p_no = p_no {
            let realm = try! Realm()
            let drug = realm.objects(Drug.self).filter("p_no == \(p_no)").first
            
//            drug.img
            let url = URL(string: drug!.img)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
//                    self.imageView.image = UIImage(data: data!)
                   
                }
            }
        }
    }

    private func addPullUpController(animated: Bool) {
           let pullUpController = makeEventTableViewControllerIfNeeded()
           _ = pullUpController.view // call pullUpController.viewDidLoad()
           addPullUpController(pullUpController,
                               initialStickyPointOffset: pullUpController.initialPointOffset,
                               animated: animated)
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
