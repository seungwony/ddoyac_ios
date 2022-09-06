//
//  SearchMarkViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/14.
//

import UIKit
import Foundation
protocol MarkPickerDelegate {
    func selectedMark(img_src:String)
}

class SearchMarkViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var items : [MarkModel] = []
    var result : [MarkModel] = []
    var delegate : MarkPickerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        initCollectionView()
        
        initData()
        // Do any additional setup after loading the view.
    }
    
    func initCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (view.frame.width - 50)/4, height: (view.frame.width)/4) // item size
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // here you can add space to 4 side of item
        
        collectionView.collectionViewLayout = layout
        
    }
    
    class func create() -> SearchMarkViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! SearchMarkViewController
    }
    
    func initData(){
        
        if let path = Bundle.main.path(forResource: "mark_list", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let contents = data.components(separatedBy: .newlines)
//                TextView.text = myStrings.joined(separator: ", ")
                
                
                for content in contents {
                    let splited = content.components(separatedBy: ", ")
                    
                    
                    if splited.count == 2 {
                        
//                        print("img : \(splited[0]) des : \(splited[1])")
                        items.append( MarkModel(img_src: splited[0], des: splited[1]) )
                    }else if splited.count == 1 {
//                        print("img : \(splited[0]) des : \("")")
                        items.append(  MarkModel(img_src: splited[0], des: ""))
                    }
                }
                
            } catch {
                print(error)
            }
        }
        
        
        for i in items {
            result.append(i)
        }
        
//        for r in result{
//            print(r.img_src)
//        }
        
        collectionView.reloadData()
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
        dismiss(animated: true, completion: nil)
    }
    
}


extension SearchMarkViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = result[indexPath.row]
        
        if let delegate  = self.delegate, let img = item.img_src {
            delegate.selectedMark(img_src: img)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkCollectionViewCell", for: indexPath) as! MarkCollectionViewCell
        
        let item = result[indexPath.row]
        
        
        let des = item.des

//        cell.imgView.image
        if let img_src = item.img_src {
            let url = URL(string: img_src)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url!){
                    DispatchQueue.main.async {
        //                cell.previewImg.image = UIImage(data: data!)
                        
                            UIView.transition(with: cell.imgView,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: { cell.imgView.image = UIImage(data: data) },
                                              completion: nil)
                        
                       
                    }
                } //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                
            }
        }
        
        return cell
    }
    
    
}
extension SearchMarkViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         print("search button click")
        searchBar.resignFirstResponder()

        
        
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        print("\(searchText)")
        result.removeAll()
        if searchText.count > 0 {
            for i in items {
                if i.des.contains(searchText) {
                    result.append(i)
                }
            }
        }else{
            for i in items {
            
                result.append(i)
                
            }
        }
        
        collectionView.reloadData()
//        self.searchWithFilter()
    }
}
