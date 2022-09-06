//
//  FilterViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/11.
//

import UIKit
import RealmSwift
import MaterialComponents.MaterialChips

protocol FilterSetDelegate {
    func setFilterBundle(filterBundle:FilterBundle)
}



class FilterViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var shapeCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var shapeCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var markPreview: UIImageView!
    @IBOutlet weak var colorCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var preresultCollectionView: UICollectionView!
    @IBOutlet weak var filterResultLabel: UILabel!
    var items:[Drug] = []
    var shapeFilters :[FilterInfo] = []
    var colorFilters :[FilterInfo] = []
    var mark_img : String?
    var filterBundle : FilterBundle?
    
    var delegate : FilterSetDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alpha = 0
        searchBar.delegate = self
//        let layout = MDCChipCollectionViewFlowLayout()
//        layout.minimumLineSpacing = 10
////        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        shapeCollectionView.collectionViewLayout = layout
        preresultCollectionView.delegate = self
        preresultCollectionView.dataSource = self
        
        shapeCollectionView.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
            
        shapeCollectionView.delegate = self
        shapeCollectionView.dataSource = self
        shapeCollectionView.allowsMultipleSelection = true
        
        shapeCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shapeCollectionView.delaysContentTouches = false
            
//        colorCollectionView.collectionViewLayout = layout
        
        colorCollectionView.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
            
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.allowsMultipleSelection = true
        colorCollectionView.delaysContentTouches = false
        colorCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Do any additional setup after loading the view.
        
        initFilterset()
                   
        self.hideKeyboardWhenTappedAround()
        
        searchWithFilter()
    }
    
    func searchWithFilter(){
        
        
        resetFilterBundle()
        
        let realm = try! Realm()
        var drugs = realm.objects(Drug.self)
        
        let max_drug_count = drugs.count
       
        if let keyword = searchBar.text, keyword.count > 1 {
            drugs = drugs.filter("searchable CONTAINS[c] '"+keyword+"'")
            print("drugs : \(drugs.count)")
        }
        
        if let filter = filterBundle {
            
            if let mark_img = filter.mark {
                
                print(mark_img)
                let mark_img_filter_query = "mark_img_front == '"+mark_img+"' OR mark_img_back == '" + mark_img + "'"
                
                
                let predicate = NSPredicate(format:mark_img_filter_query)
                drugs = drugs.filter(predicate)
                
                
                print("\(mark_img_filter_query) count : \(drugs.count)")
            }
        
            if filter.shape_list.count > 0 {
                var shape_filter_query = ""
                var count = 0
                for shape in filter.shape_list {

                    
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
                
             
//                print(color_filter_query)
                let predicate = NSPredicate(format:color_filter_query)
                drugs = drugs.filter(predicate)
                
            }
            
      
        }
        
      
        
        if items.count > 0{
            items.removeAll()
        }

        let MAX_RESULT = 10
      
        var count = 0
        for drug in drugs {
            items.append(drug)
            
            count = count + 1
            
            if count == MAX_RESULT {
                break
            }
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if max_drug_count != drugs.count {
            if let formattedNumber = numberFormatter.string(from: NSNumber(value:drugs.count)) {
                
                
                filterResultLabel.text = "\(formattedNumber)개의 결과가 나옵니다."
            }else{
                filterResultLabel.text = "찾으시는 결과가 나오지 않습니다."
            }
        }else{
            filterResultLabel.text = "필터를 설정해주세요."
        }
       
        
        
        preresultCollectionView.reloadData()
//        tableView.reloadData()
        
    }
    
    func setCurrentFilterData(){
        
        var idx = 0
        for (name, hex) in DBColorNames.colorMapKor {
            print("\(name) : \(idx)")
            var color = FilterInfo(type: "color", name: name)
            color.hexCode = hex
            color.order = DBColorNames.colorIndex[name] ?? idx
            if let bundle = self.filterBundle{
                
                let selected_colors = bundle.colors
                for selected_color in selected_colors {
                    if selected_color == color.name {
                        color.selected = true
                    }
                }
                
            }
            
            
            
            colorFilters.append(color)
            
            idx = idx + 1
            
        }
        colorFilters = colorFilters.sorted(by: { $0.order < $1.order })
        
        idx = 0
        for s in LabelHelper.shapes {
            var shape = FilterInfo(type: "shape", name: s)
            shape.order = idx
            
            
            if let bundle = self.filterBundle {
                let selected_shapes = bundle.shape_list
                
                
                for selected_shape in selected_shapes {
                    
//                    print("selected : \(selected_shape) shape.name : \(shape.name) compared : \(selected_shape == shape.name)")
                    shape.selected = selected_shape == shape.name
                    
                }
            }
            
//            if shape.selected {
//                print("\(shape.name) : \(shape.selected)")
//            }
            
            shapeFilters.append(shape)
            
            idx = idx + 1
        }
        shapeFilters = shapeFilters.sorted(by: { $0.order < $1.order })
        
        if let bundle = self.filterBundle {
            let keyword = bundle.keyword
            
            
            searchBar.text = keyword
           
            
            if let mark = bundle.mark {
                let url = URL(string: mark)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url!){
                        DispatchQueue.main.async {
                            self.markPreview.image = UIImage(data: data)
                        }
                    }
                }
            }
            
            
            
            
            mark_img = bundle.mark
            
            
            
            
        }
        
        for i in 0 ..< shapeFilters.count {
            let sf = shapeFilters[i]
//            sf.name
            print("\(sf.name) : \(sf.selected)")
        }
        
    }
    
    func setColors(colors:[String]){
        filterBundle?.colors.removeAll()
        for c in colors {
            filterBundle?.colors.append(c)
        }
        
        
        for i in 0 ..< colorFilters.count {
            colorFilters[i].selected = false
            for c in colors {
                if c == colorFilters[i].name {
                    colorFilters[i].selected = true
                }
            }
        }
        
        colorCollectionView.reloadData()
        
//        initFilterset()
        searchWithFilter()
    }
    
    @IBAction func onClickColorRed(_ sender: Any) {
        let colors = ["빨강", "주황", "갈색"]
        setColors(colors:colors)
        
    }
    
    @IBAction func onClickColorOrange(_ sender: Any) {
        let colors = ["빨강", "주황", "갈색", "노랑"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorYellow(_ sender: Any) {
        let colors = ["주황", "갈색", "노랑"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorGreen(_ sender: Any) {
        let colors = ["연두", "청록", "초록"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorBlue(_ sender: Any) {
        let colors = ["파랑", "청록", "남색"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorPurple(_ sender: Any) {
        let colors = ["보라", "분홍", "자주"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorBright(_ sender: Any) {
        let colors = ["하양", "노랑", "투명"]
        setColors(colors:colors)
    }
    @IBAction func onClickColorDark(_ sender: Any) {
        let colors = ["갈색", "검정", "진한", "남색", "회색"]
        setColors(colors:colors)
    }
    
    
    func initFilterset(){
        
        setCurrentFilterData()
//        self.setCurrentFilterData()
        
        
        shapeCollectionView.reloadData()
        colorCollectionView.reloadData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.setHeight()
            let layout = MDCChipCollectionViewFlowLayout()
            layout.minimumLineSpacing = 10
    //        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
           
            
            let layout2 = MDCChipCollectionViewFlowLayout()
            layout2.minimumLineSpacing = 10
    //        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
           
            
            self.shapeCollectionView.collectionViewLayout = layout
            self.colorCollectionView.collectionViewLayout = layout2

            //setHeight()
        

    //        if collectionView as self.shapeCollectionView {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {


                self.shapeCollectionViewHeight.constant =  self.shapeCollectionView.contentSize.height

                self.colorCollectionViewHeight.constant =  self.colorCollectionView.contentSize.height

                
                UIView.animate(withDuration: 0.3) {
                    self.scrollView.alpha = 1
                }
                
            }


//        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.setHeight()
//        })
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func setHeight(){
        
        
        self.shapeCollectionView.layoutIfNeeded()
        self.shapeCollectionViewHeight.constant =  self.shapeCollectionView.contentSize.height
        self.shapeCollectionView.reloadData()
        
        self.colorCollectionView.layoutIfNeeded()
        self.colorCollectionViewHeight.constant =  self.colorCollectionView.contentSize.height
        self.colorCollectionView.reloadData()
    }
    
    class func create() -> FilterViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! FilterViewController
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickMarkPicker(_ sender: Any) {
        let vc = SearchMarkViewController.create()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        

    }
    
    @IBAction func onClickMore(_ sender: Any) {
        search()
    }
    
    @IBAction func onClickReset(_ sender: Any) {
        searchBar.text = ""
        
        for i in 0 ..< colorFilters.count {
            colorFilters[i].selected = false
            
        }
        
        for i in 0 ..< shapeFilters.count {
            shapeFilters[i].selected = false
            
        }
        
        colorCollectionView.reloadData()
        shapeCollectionView.reloadData()
        self.markPreview.image = nil
        
//                    print(img_src)
        self.mark_img = nil
        
        searchWithFilter()
        
        
    }
    @IBAction func onClickSearch(_ sender: Any) {
        
       
       search()
        
        
        
        
        
        
    }
    
    
    func search(){
        var newfilterBundle  = FilterBundle()
       for shape in shapeFilters {
           if shape.selected {
               
               newfilterBundle.shape_list.append(shape.name)
           }
           
           
       }
       
       for color in colorFilters {
           if color.selected {
               
               newfilterBundle.colors.append(color.name)
           }
           
       }
       
       
       if let mark = mark_img {
           newfilterBundle.mark = mark
       }
       
       newfilterBundle.keyword = searchBar.text
       
       if let delegate = self.delegate {
           if let count = navigationController?.viewControllers.count{
//                let vc = navigationController?.viewControllers[count - 2]
//                let svc = vc! as UIViewController as! SearchDrugViewController

   //            print("search click")

//                svc.setFilterBundle(filterBundle:newfilterBundle)
               delegate.setFilterBundle(filterBundle: newfilterBundle)
               navigationController?.popViewController(animated: true)
           }
       }else{
           let navc = navigationController
           navc?.hero.isEnabled = true
           navc?.heroNavigationAnimationType = .fade
           
           let vc = SearchDrugViewController.create()
           vc.filterBundle = newfilterBundle
           if let keyword = searchBar.text {
               vc.keyword = keyword
           }
//            navc?.popViewController(animated: false)
//
//            if var vcarray = navc?.viewControllers {
//                vcarray.removeLast()
//                vcarray.append(vc)
//                navc?.setViewControllers(vcarray, animated: true)
//            }
           
           navc?.pushViewController(vc, animated: true)
           
       }
    }
    
    
    func resetFilterBundle(){
        var newfilterBundle  = FilterBundle()
       for shape in shapeFilters {
           if shape.selected {
               
               newfilterBundle.shape_list.append(shape.name)
           }
           
           
       }
       
       for color in colorFilters {
           if color.selected {
               
               newfilterBundle.colors.append(color.name)
           }
           
       }
        
        newfilterBundle.mark = mark_img
       
       newfilterBundle.keyword = searchBar.text
        
        filterBundle = newfilterBundle
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func log(){
        
        print(searchBar.text!)
        var newfilterBundle  = FilterBundle()
       for shape in shapeFilters {
           if shape.selected {
               
//               print("sel : \(shape.name)")
               newfilterBundle.shape_list.append(shape.name)
           }
       }
       
       for color in colorFilters {
           if color.selected {
               
//               print("sel : \(color.name)")
               newfilterBundle.colors.append(color.name)
           }else{
//               print("unsel : \(color.name)")
           }
       }
    }
    
}
extension FilterViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.shapeCollectionView == collectionView {
            return shapeFilters.count
        }else if self.colorCollectionView == collectionView {
            return colorFilters.count
        }else if self.preresultCollectionView == collectionView {
            return items.count
        }
       return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView != self.preresultCollectionView {
            let cell: MDCChipCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath) as! MDCChipCollectionViewCell
                
                let chipView = cell.chipView
            
            self.autoItemSize(collectionView)
            
            
            if self.shapeCollectionView == collectionView {
                
                shapeFilters[indexPath.row].selected = false
//                print("\(shapeFilters[indexPath.row].name) : \(shapeFilters[indexPath.row].selected)")
//                resetFilterBundle()
            }else if self.colorCollectionView == collectionView {
                
                colorFilters[indexPath.row].selected = false
//                print("\(colorFilters[indexPath.row].name) : \(colorFilters[indexPath.row].selected)")
//                resetFilterBundle()
            }
            self.searchWithFilter()
        }
        
        
        

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.preresultCollectionView {
            let cell: MDCChipCollectionViewCell = collectionView.cellForItem(at: indexPath) as! MDCChipCollectionViewCell
                
                let chipView = cell.chipView
    //        chipView.imagePadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -50)
            
            
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
            
            self.autoItemSize(collectionView)
            
            if self.shapeCollectionView == collectionView {
                
                shapeFilters[indexPath.row].selected = true
    //            resetFilterBundle()
    //            print("\(shapeFilters[indexPath.row].name) : \(shapeFilters[indexPath.row].selected)")
                
            }else if self.colorCollectionView == collectionView {
                
                colorFilters[indexPath.row].selected = true
    //            resetFilterBundle()
    //            print("\(colorFilters[indexPath.row].name) : \(colorFilters[indexPath.row].selected)")
            }
            self.searchWithFilter()
        }else{
            let item = items[indexPath.row]
           
   
            let cell: PreresultCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PreresultCollectionViewCell

            let navc = navigationController
            navc?.hero.isEnabled = true
            navc?.heroNavigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            
            
            
            
            let vc = DetailViewController.create()
    //        vc.modalPresentationStyle = .overCurrentContext
            vc.hero.isEnabled = true
            vc.p_no = item.p_no
            vc.id = item.id
            vc.p_name = item.p_name
            vc.getImg = cell.previewImg.image
            vc.name_hero_id = "name\(indexPath.row)"
            vc.img_hero_id = "img\(indexPath.row)"
            

//            print(cell.nameLabel.text)
            
            navc?.pushViewController(vc, animated: true)
            
            collectionView.deselectItem(at: indexPath, animated: true)
        }

//        log()
    }
    
    
    func autoItemSize(_ collectionView: UICollectionView){
        let layout = MDCChipCollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        
        //setHeight()
        
//        if collectionView as self.shapeCollectionView {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            if collectionView == self.shapeCollectionView {
                self.shapeCollectionViewHeight.constant =  collectionView.contentSize.height
            }else{
                self.colorCollectionViewHeight.constant =  collectionView.contentSize.height
            }
            
        }
//        }
//        self.colorCollectionViewHeight.constant =  self.collectionView.contentSize.height
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == self.preresultCollectionView{
            let cell: PreresultCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreresultCollectionViewCell", for: indexPath) as! PreresultCollectionViewCell
            
            cell.tag = indexPath.row
            let item = items[indexPath.row]
            let url = URL(string: item.img)
            cell.nameLabel.text = item.p_name
            cell.nameLabel.hero.id = "name\(indexPath.row)"
            cell.previewImg.hero.id = "img\(indexPath.row)"
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url!){
                    DispatchQueue.main.async {
//                        cell.previewImg.image = UIImage(data: data)
                        if cell.tag == indexPath.row {
                            UIView.transition(with: cell.previewImg,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: {
                                                cell.previewImg.image = UIImage(data: data)
                                                
                                                
                                              },
                                              completion: nil)
                        }
                       
                    }
                } //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                
            }
            return cell
        }else{
            let cell: MDCChipCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath) as! MDCChipCollectionViewCell
                
                let chipView = cell.chipView
            
            
            chipView.selectedImageView.image = UIImage(named: "ic_check")
                chipView.titleFont = UIFont.systemFont(ofSize: 16)
            chipView.titleLabel.minimumScaleFactor = 0.7
            chipView.titleLabel.adjustsFontSizeToFitWidth = true
    //        chipView.setRippleColor(.blue, for: .normal)
            chipView.selectedImageView.tintColor = .label
            chipView.setBackgroundColor(UIColor.secondarySystemBackground, for: .normal)
            chipView.setBackgroundColor(UIColor.systemBlue, for: .selected)
            chipView.setTitleColor(UIColor.label, for: .normal)
            
    //            chipView.titleLabel.text = "tesddt"
            //chipView.contentPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    //        chipView.isSelected
            //cell.alwaysAnimateResize = true
            
    //        chipView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
              
    //        chipView.setBorderWidth(2, for: UIControl.State.normal)
     
    //        layout.estimatedItemSize
            
           
            if self.shapeCollectionView == collectionView {
                let shape = shapeFilters[indexPath.row]
                chipView.titleLabel.text = shape.name
                chipView.titleLabel.sizeToFit()
    //            chipView.titleLabel.adjustsFontSizeToFitWidth = true
                cell.isSelected = shape.selected
                if shape.selected {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                }

//                print("row shape : \(shape.name) selected: \(shape.selected)")

                
            }else if self.colorCollectionView == collectionView {
                
                let color = colorFilters[indexPath.row]
                chipView.titleLabel.text = color.name
                chipView.isSelected = color.selected
                chipView.titleLabel.sizeToFit()
                cell.isSelected = color.selected
                if color.selected {
                    
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                }
                if let rgb = DBColorNames.colorMapKor[color.name], let uicolor = DBColorNames.colorConvert(fromRGBFloat: rgb) {
                    chipView.imageView.image = uicolor.image(CGSize(width: 22, height: 22))
                    chipView.imageView.tintColor = UIColor.label
                    chipView.imageView.layer.cornerRadius = 8.0
                    chipView.imageView.clipsToBounds = true
                    chipView.imageView.sizeToFit()
                }
                
                
                
                
    //            chip.imageView.image = UIImage(named: "ic_color_dropper_picker")
                
              
            }
            return cell
        }
        
      
        
        //chipView.titleLabel.numberOfLines = 0
        
    }
    
    
   
}
extension FilterViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         print("search button click")
        searchBar.resignFirstResponder()
        self.searchWithFilter()
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        print("\(searchText)")
        self.searchWithFilter()
    }
}

extension FilterViewController : MarkPickerDelegate {
    
    func selectedMark(img_src:String){
//        markPreview.image
        let url = URL(string: img_src)
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){
                DispatchQueue.main.async {
                    self.markPreview.image = UIImage(data: data)
                    
//                    print(img_src)
                    self.mark_img = img_src
                    
//                    if let fb = self.filterBundle, let mark = fb.mark {
//                        print(mark)
//                    }
                    
                    self.searchWithFilter()
                }
            }
        }
        
        
        
        
    }
}
