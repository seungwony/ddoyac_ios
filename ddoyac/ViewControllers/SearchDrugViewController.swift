//
//  SearchDrugViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/21.
//

import UIKit
import RealmSwift
import Hero
import MaterialComponents.MaterialChips

class SearchDrugViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var scrollView: UIScrollView!
    private var originalPullUpControllerViewSize: CGSize = .zero
    @IBOutlet weak var tableView: UITableView!
    var filterBundle :FilterBundle?
    
    var items:[Drug] = []
    
    var filter_list : [FilterInfo] = []
    
    var filter_items:[DrugModel] = []
    var keyword:String?
    
    var tagXOffset = 10
      var tagPadding = 10
    class func create() -> SearchDrugViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! SearchDrugViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.isHeroEnabled = true
       
        searchBar.delegate = self
        
        
        // Do any additional setup after loading the view.
        setFilterUI()
        
        searchWithFilter()
        
//        openFilterView()
        
        self.hideKeyboardWhenTappedAround()
        
//        dummyFilters()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.addPullUpController(animated: true)
//
//        }
//        removePrviousFilterView()
    }
    
    
//    func removePrviousFilterView(){
//        if let nav = navigationController {
//            for vc in nav.viewControllers {
//
//                if vc.view.isKind(of: FilterViewController.self){
//                    nav.popToViewController(vc, animated: false)
//                }
//            }
//        }
//
//    }
    
    
//    func setFilterBundle(filterBundle :FilterBundle){
//        self.filterBundle = filterBundle
//        
//        
//        
//        print("setFilterBundle")
//        removeAllChip()
//        
//            self.setFilterUI()
//            
//            self.searchWithFilter()
//        
//        
//    }
    
    func setFilterUI(){
        if let filter = filterBundle {
            if let keyword = filter.keyword {
                searchBar.text = keyword
            }
            
            for shape in filter.shape_list {
                
             //   print(shape)
                addChip(type: "shape", name:shape)
            }
            
//            if let shape = filter.shape {
//                for s in LabelHelper.getShapesForFilter(shape: shape) {
//                    addChip(type: "shape", name:s)
//                }
//
//            }
            
            for color in filter.colors {
               // print(color)
                addChip(type: "color", name:color)
            }
            
            
            if let mark_img = filter.mark {
                addChip(type: "mark", name:mark_img)
            }
        }
    }
    
    
    
  
    func addChip(type: String, name:String)
        {
  
        
            let chip = MDCChipView()
            chip.titleLabel.text = name
        chip.setBackgroundColor(UIColor.secondarySystemBackground, for: .normal)
//        chip.backgroundColor = UIColor.secondarySystemBackground
        chip.setTitleColor(UIColor.label, for: .normal)
//        chip.selectedImageView.image = UIImage(named: "AppIcon")
        
        if type == "color" {
            
            if let rgb = DBColorNames.colorMapKor[name], let uicolor = DBColorNames.colorConvert(fromRGBFloat: rgb) {
                chip.imageView.image = uicolor.image(CGSize(width: 22, height: 22))
            }
            
            
            
//            chip.imageView.image = UIImage(named: "ic_color_dropper_picker")
            chip.imageView.sizeToFit()
          
        }
        
        if type == "shape" {
//            let uiimg = UIImage(named: "ic_shape_filter")
//            uiimg.
//            chip.imageView.image =
//            chip.imageView.sizeToFit()
        }
        
        if type == "mark" {
            chip.titleLabel.text = "마크"
            let url = URL(string: name)
//            DispatchQueue.global().async {
//                if let data = try? Data(contentsOf: url!){
//                    DispatchQueue.main.async {
//
//                    }
//                }
//            }
            
            if let data = try? Data(contentsOf: url!), let uiimg = UIImage(data: data){
                let resizedImg = self.resizeImage(image:uiimg , targetSize: CGSize(width: 24, height: 24))
                chip.imageView.image = resizedImg
                chip.imageView.sizeToFit()
            }
            
            
        }
        
        
        chip.imageView.tintColor = UIColor.label
        chip.imageView.layer.cornerRadius = 8.0
        chip.imageView.clipsToBounds = true
        
        chip.titleFont = UIFont.systemFont(ofSize: 16)
        chip.titleLabel.minimumScaleFactor = 0.7
        chip.titleLabel.adjustsFontSizeToFitWidth = true

        //        chipView.setRippleColor(.blue, for: .normal)
        
        chip.selectedImageView.tintColor = .label
        chip.setBackgroundColor(UIColor.secondarySystemBackground, for: .normal)
//        chip.setBackgroundColor(UIColor.systemBlue, for: .selected)
        chip.setTitleColor(UIColor.label, for: .normal)
    
//        chip.imageView
            chip.sizeToFit()
//        chip.accessoryView = cellAudioButton
//        chip.removeicon
//            chip.addTarget(self, action: #selector(removeChip), for: .touchUpInside)
            scrollView.addSubview(chip)
        chip.frame.origin.x = CGFloat(tagXOffset)
            chip.frame.origin.y = 10
        tagXOffset += tagPadding + Int(chip.frame.width)
        
        scrollView.contentSize = CGSize(width: tagXOffset, height: 51)
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size

       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height

       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }

       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
   }
    
    func removeAllChip(){
        tagXOffset = 10
        tagPadding = 10
        for subview in scrollView.subviews {
            if subview is MDCChipView {
                subview.removeFromSuperview()
            }
        }
    }
    
    @objc func removeChip(sender: MDCChipView!)
        {
            tagXOffset = tagPadding
            sender.removeFromSuperview()
            for subview in scrollView.subviews {
                subview.frame.origin.x = CGFloat(tagXOffset)
                tagXOffset += tagPadding + Int(subview.frame.width)
            }
        }
    
    func searchWithFilter(){
        let realm = try! Realm()
        var drugs = realm.objects(Drug.self)
        
       
       
        
        
        if let keyword = searchBar.text, keyword.count > 1 {
            filterBundle?.keyword = keyword
            drugs = drugs.filter("searchable CONTAINS[c] '"+keyword+"'")
           // print("drugs : \(drugs.count)")
        }
        
        if let filter = filterBundle {
        
            if let mark_img = filter.mark {
                let mark_img_filter_query = "mark_img_front == '"+mark_img+"' OR mark_img_back == '" + mark_img + "'"
                let predicate = NSPredicate(format:mark_img_filter_query)
                drugs = drugs.filter(predicate)
            }
            
            if filter.shape_list.count > 0 {
                var shape_filter_query = ""
                var count = 0
                for shape in filter.shape_list {
//                    addChip(type: "shape", name:shape)
                    
                    count = count + 1
                    shape_filter_query = shape_filter_query + "shape == '"+shape+"'"
                    
                    if filter.shape_list.count != count {
                        shape_filter_query = shape_filter_query + " OR "
                    }
                }
                
//                print(shape_filter_query)
                let predicate = NSPredicate(format:shape_filter_query)
                drugs = drugs.filter(predicate)
            }
            
            
            
            if filter.colors.count > 0 {
                var color_filter_query = ""
                var count = 0
                for color in filter.colors {
                    
//                    print(color)
                    count = count + 1
    //                addChip(type: "color", name:color)
                    
                    
                    color_filter_query = color_filter_query +  "color_front contains '"+color+"' OR color_back contains '" + color + "'"
                    
                    
    //                print("color filter drugs : \(drugs.count)")
                    
                    if filter.colors.count != count {
                        color_filter_query = color_filter_query + " OR "
                    }
                }
                
             
                //print(color_filter_query)
                let predicate = NSPredicate(format:color_filter_query)
                drugs = drugs.filter(predicate)
                
            }
            
      
        }
        
        if items.count > 0{
            items.removeAll()
        }
        
        for drug in drugs {
            items.append(drug)
        }
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func onClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickFilter(_ sender: Any) {
        
        openFilterView()
    }
    
    
    func openFilterView(){
        let vc = FilterViewController.create()
        vc.filterBundle = filterBundle
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func makeEventTableViewControllerIfNeeded() -> PullFilterViewController {
         let currentPullUpController = children
             .filter({ $0 is PullFilterViewController })
             .first as? PullFilterViewController
        
        let pullUpController = currentPullUpController ??  PullFilterViewController.create()
        
        
//        pullUpController.p_no = p_no

         pullUpController.initialState = .contracted
         if originalPullUpControllerViewSize == .zero {
             originalPullUpControllerViewSize = pullUpController.view.bounds.size
         }

         return pullUpController
     }
    
    private func addPullUpController(animated: Bool) {
           let pullUpController = makeEventTableViewControllerIfNeeded()
           _ = pullUpController.view // call pullUpController.viewDidLoad()
           addPullUpController(pullUpController,
                               initialStickyPointOffset: pullUpController.initialPointOffset,
                               animated: animated)
       }
}

extension SearchDrugViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       //  print("search button click")
        searchBar.resignFirstResponder()
        self.searchWithFilter()
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
      //  print("\(searchText)")
        self.searchWithFilter()
    }
}
extension SearchDrugViewController :  UITableViewDelegate, UITableViewDataSource {
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

extension SearchDrugViewController : FilterSetDelegate{
    func setFilterBundle(filterBundle:FilterBundle){
        self.filterBundle = filterBundle
        
        
        
//        print("setFilterBundle")
        removeAllChip()
        
            self.setFilterUI()
            
            self.searchWithFilter()
    }
   
}
