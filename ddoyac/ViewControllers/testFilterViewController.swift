//
//  testFilterViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/11.
//

import UIKit
import MaterialComponents.MaterialChips
class testFilterViewController: UIViewController {

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView2Height: NSLayoutConstraint!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = MDCChipCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        
        collectionView.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
            
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        
        
        collectionView2.collectionViewLayout = layout
        
        collectionView2.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
            
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
        
//        collectionViewHeight.constant =  self.collectionView.contentSize.height
//
//
//        collectionView2Height.constant = self.collectionView2.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setHeight()
        }
 
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func setHeight(){
        
        
        self.collectionView.layoutIfNeeded()
        self.collectionViewHeight.constant =  self.collectionView.contentSize.height
        self.collectionView.reloadData()
        
        self.collectionView2.layoutIfNeeded()
        self.collectionView2Height.constant =  self.collectionView2.contentSize.height
        self.collectionView2.reloadData()
    }
    
    class func create() -> testFilterViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! testFilterViewController
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
extension testFilterViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 11
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let section = dailyWorkouts[indexPath.section]
//
//        let item = section.list[indexPath.row]
//
//
//        let vc = WorkoutDetailViewController.create()
//        vc.currWorkout = item
//        vc.delegate = self
//
////        self.present(vc, animated: true, completion: nil)
//
//        self.navigationController?.pushViewController(vc, animated:false)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MDCChipCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath) as! MDCChipCollectionViewCell
            
            let chipView = cell.chipView
            
            chipView.titleFont = UIFont.systemFont(ofSize: 20)
            chipView.titleLabel.text = "test"
        chipView.contentPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          
        chipView.setBorderWidth(2, for: UIControl.State.normal)

            return cell
        
    
    }
    
    
   
}

