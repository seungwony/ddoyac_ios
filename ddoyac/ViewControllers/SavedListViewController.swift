//
//  SavedListViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import UIKit
protocol SavedListDelegate {
    func selectedList(id:Int, title:String)
}
class SavedListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var items :[SavedModel] = []
    
    var rel_id:Int?
    
    var delegate : SavedListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        initSQLite()
        
//        dummy()
    }
    class func create() -> SavedListViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! SavedListViewController
    }
    
    func dummy(){
        let item1 = SavedModel(id: 0, priority: 0, name: "기본 저장 목록", created: Date().convertStringForServer)
        
        let item2 = SavedModel(id: 1, priority: 1, name: "김하나 환자 복용", created: Date().convertStringForServer)
        
        let item3 = SavedModel(id: 2, priority: 2, name: "나의 복용", created: Date().convertStringForServer)
        
        
        items.append(item1)
        items.append(item2)
        items.append(item3)
        
        
//        tableView.reloadData()
        
   
    }
    
    func initSQLite(){
        SQLiteHelper.createMainTable()
        SQLiteHelper.createRelTable()
        
        
        if SQLiteHelper.getAllListData().count == 0 {
            SQLiteHelper.initialInsert()
        }
        
        
        reloadData()
       
    }

    
    func reloadData(){
        items.removeAll()
        
        for savedModel in  SQLiteHelper.getAllListData() {
            items.append(savedModel)
        }
        
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickAddSavedList(_ sender: Any) {
        showInputDialog(title: nil, subtitle: "저장 목록 만들기", actionTitle: "추가", cancelTitle: "취소", inputText:"", inputPlaceholder: "이름을 입력해주세요.", inputKeyboardType: .default) { action in
            
            //cancel
            
            
        } actionHandler: { result in
            if let txt  = result {
                
                if txt.count > 10 {
                    let alert = UIAlertController(
                      title: "최대 10글자만 가능.",
                      message: nil,
                      preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    self.present(alert, animated: true)
                    return
                }
                
                if txt.count < 2 {
                    let alert = UIAlertController(
                      title: "너무 짧습니다.",
                      message: nil,
                      preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    self.present(alert, animated: true)
                    return
                }
                print(txt)
                let count = SQLiteHelper.getAllListData().count
//                if SQLiteHelper.getAllListData().count == 0 {
//                }
                SQLiteHelper.insertSaveData(priority:count, name:txt)
                
                self.reloadData()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    self.tableView.reloadData()
//
//                }
                
                
            }
            
        }

    }
    @IBAction func onClickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
extension SavedListViewController :  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedListTableViewCell", for: indexPath) as! SavedListTableViewCell
        
        cell.tag = indexPath.row
        
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.nameLabel.hero.id = "title\(indexPath.row)"

        let count = SQLiteHelper.getAllDrugDataById(id: item.id).count
        
        if count > 0 {
            cell.countLabel.isHidden = false
            
            
            cell.countLabel.setTitle("\(count)", for: .normal)
            
        }else{
            cell.countLabel.isHidden = true
        }
//        cell.countLabel.text =
//        print(item.img)
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DrugTableViewCell", for: indexPath) as! DrugTableViewCell
        
        print("tap : \(item.id)")

        if let rel_id = self.rel_id {
            
            if SQLiteHelper.getRelDrugData(id:item.id, rel_id: rel_id).count > 0 {
                let alert = UIAlertController(
                  title: "이미 추가했습니다.",
                  message: nil,
                  preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true)
                
                
            }else{
                
                SQLiteHelper.insertDrugData(id: item.id, rel_id: rel_id, priority: 0)
                
                
                let alert = UIAlertController(
                  title: "목록에 추가했습니다.",
                  message: nil,
                  preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true)
                self.reloadData()
                
                
            }
          
        }else{
            //open
            
            print("open list")
            let id = item.id
//            dismiss(animated: true)
            let hero_id = "title\(indexPath.row)"
            
//            let vc = DrugsInSavedListViewController.create()
//            vc.id = id
//            vc._title = item.name
//            vc.title_hero_id = hero_id
//            present(vc, animated: true, completion: nil)
            
//            navigationController?.pushViewController(vc, animated: true)
//
            dismiss(animated: true, completion: nil)
            if let delegate = self.delegate {
                delegate.selectedList(id: item.id, title: item.name)
            }
            
            
        }
        
//        item.id
    }
    
    
}


