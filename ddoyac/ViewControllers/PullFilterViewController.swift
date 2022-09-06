//
//  PullFilterViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/11.
//

import UIKit

class PullFilterViewController: PullUpController {
    enum InitialState {
       case contracted
       case expanded
   }
    @IBOutlet weak var colorCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shapeCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var shapeCollectionView: UICollectionView!
    @IBOutlet weak var PreviewNullObject: UIView!
    private var safeAreaAdditionalOffset: CGFloat {
        hasSafeArea ? 20 : 0
    }
    @IBOutlet weak var scrollView: UIScrollView!
    var initialState: InitialState = .contracted
        
     var initialPointOffset: CGFloat {
           switch initialState {
           case .contracted:
               return (PreviewNullObject.frame.height) + safeAreaAdditionalOffset
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
    class func create() -> PullFilterViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! PullFilterViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: view.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)

        // Do any additional setup after loading the view.
        scrollView.attach(to: self)
        
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
        
//        if stickyPoint == pullUpControllerPreferredSize.height{
//            webView.isUserInteractionEnabled = true
//        }else{
//            webView.isUserInteractionEnabled = false
//        }
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
          return [PreviewNullObject.frame.maxY]
      case .expanded:
          return [PreviewNullObject.frame.maxY + safeAreaAdditionalOffset, PreviewNullObject.frame.maxY]
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
