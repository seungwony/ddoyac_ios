//
//  DrugsInSavedListViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import UIKit
import RealmSwift
import Hero
class DrugsInSavedListViewController: UIViewController {
    var items:[Drug] = []
    
    var title_hero_id : String?
    
    @IBOutlet weak var titleLabel: UILabel!
    var id:Int?
    var _title:String?
    var filter_items:[DrugModel] = []
    @IBOutlet weak var tableView: UITableView!
    
    class func create() -> DrugsInSavedListViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! DrugsInSavedListViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = false
        
        if let title = _title {
            titleLabel.text = title
            
        }
        
            
//        self.tableView.register(DrugTableViewCell.self, forCellReuseIdentifier: "DrugTableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
        
        if let id = self.id {
            let ids = SQLiteHelper.getAllDrugDataById(id: id)
            
            
            let realm = try! Realm()
            var drugs = realm.objects(Drug.self)
            drugs = drugs.filter("id IN %@", ids)
//            drugs = drugs.reversed()
            
            if items.count > 0{
                items.removeAll()
            }
            
            for drug in drugs.reversed() {
                items.append(drug)
            }
            
            tableView.reloadData()
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
    @IBAction func onClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        var str = ""
        
        var count = 0
        let max_count = items.count
        for item in items {
            str = str + item.p_name
            
            count = count + 1
            
            if count != max_count {
                str = str + ", "
            }
        }
        presentShareViewConroller(copyString: str)
    }
    
    @IBAction func onClickExtra(_ sender: Any) {
        presentExtraViewConroller()
    }
}
extension DrugsInSavedListViewController :  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugTableViewCell", for: indexPath) as! DrugTableViewCell
        
        cell.tag = indexPath.row
        
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.p_name
        cell.nameLabel.hero.id = "name\(indexPath.row)"

//        print(item.img)
        
        cell.previewImg.hero.id = "img\(indexPath.row)"
        let url = URL(string: item.img)
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){
                DispatchQueue.main.async {
    //                cell.previewImg.image = UIImage(data: data!)
                    if cell.tag == indexPath.row {
                        UIView.transition(with: cell.previewImg,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: { cell.previewImg.image = UIImage(data: data) },
                                          completion: nil)
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugTableViewCell", for: indexPath) as! DrugTableViewCell
        
        let cell = tableView.cellForRow(at: indexPath) as! DrugTableViewCell
//        let vc = PullableDetailViewController.create()
//        vc.p_no = item.p_no
//        vc.hero.isEnabled = true
//        vc.imageView.hero.id = "img\(indexPath.row)"
//
//        vc.imageView.image = cell.previewImg.image
//
//        let name = cell.nameLabel.text
//
//        vc.p_name = name
//        vc.nameLabel.hero.id = "name\(indexPath.row)"
        let navc = navigationController
        navc?.hero.isEnabled = true
        navc?.heroNavigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        
        
        
        
        let vc = DetailViewController.create()
//        vc.modalPresentationStyle = .overCurrentContext
        vc.hero.isEnabled = true
        
        vc.id = item.id
        vc.p_no = item.p_no
        vc.p_name = cell.nameLabel.text
        vc.getImg = cell.previewImg.image
        vc.name_hero_id = "name\(indexPath.row)"
        vc.img_hero_id = "img\(indexPath.row)"
//        vc.hero.modalAnimationType =
//            .push(direction: .right)
//        vc.hero.modalAnimationType = .selectBy(presenting: .pull(direction: .up), dismissing: .slide(direction: .down))
//        vc.hero.modalAnimationType = .zoom
//        vc.isModalInPresentation = true
//        vc.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .up))
//        vc.visualEffectView.hero.modifiers = [.fade, .useNoSnapshot]
//        self.present(vc, animated: true)
        navc?.pushViewController(vc, animated: true)
//        altOpen(p_no: item.p_no)
    }
    
    
}



extension DrugsInSavedListViewController: DrawerPresentationControllerDelegate {
    func drawerMovedTo(position: DraweSnapPoint) {
        
    }
    
    func presentShareViewConroller(copyString:String) {
        let viewController = ShareViewController.create()
        viewController.copyContent = copyString
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            self.present(viewController, animated: true)
        }
    func presentExtraViewConroller() {
        print("presentExtraViewConroller")
        let viewController = ModifySavedListViewController.create()
//        viewController.copyContent = copyString
        viewController.delegate = self
        
        if let id = self.id, let title = _title {
            let saved = SavedModel(id: id, priority: 0, name: title, created: Date().convertStringForServer)
            viewController.savedModel = saved
        }
        
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            self.present(viewController, animated: true)
        }
    
   
}

extension DrugsInSavedListViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController =  DrawerPresentationController(presentedViewController: presented, presenting: presenting, blurEffectStyle: .regular)
        presentationController.cornerRadius = 20
        presentationController.roundedCorners = [.topLeft, .topRight]
        presentationController.bounce = false
        presentationController.topGap = 200
        
        return presentationController
    }
}


extension DrugsInSavedListViewController: ModifySavedListDelegate{
    func modifiedName(name:String){
        _title = name
        titleLabel.text = name
        
        
    }
    func removed(){
        navigationController?.popViewController(animated: true)
    }
}
