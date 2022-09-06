//
//  ModifySavedListViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import UIKit
protocol ModifySavedListDelegate {
    func modifiedName(name:String)
    func removed()
}
class ModifySavedListViewController: UIViewController {

    @IBOutlet weak var modifyButton: RoundButton!
    var delegate : ModifySavedListDelegate?
    var savedModel: SavedModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if let saved = savedModel {
            let name = saved.name
            
            modifyButton.setTitle(name, for: .normal)
        }
    }

    class func create() -> ModifySavedListViewController {
          let modifySavedListViewController = ModifySavedListViewController(nibName: "ModifySavedListViewController", bundle: nil)
        
          return modifySavedListViewController
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickRemove(_ sender: Any) {
        
            
        guard let saved = savedModel else {
            return
        }
        SQLiteHelper.deleteDrugData(id:saved.id)
        SQLiteHelper.deleteData(id: saved.id)
        
        dismiss(animated: true, completion: nil)
        delegate?.removed()
    }
    
    @IBAction func onClickModifyName(_ sender: Any) {
        
        guard let saved = savedModel else {
            return
        }
        
        
        showInputDialog(title: nil, subtitle: "저장 목록 수정하기", actionTitle: "수정", cancelTitle: "취소", inputText:saved.name, inputPlaceholder: "이름을 입력해주세요.", inputKeyboardType: .default) { action in
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
//                print(txt)
                SQLiteHelper.updateSavedListName(id:saved.id, name:txt)
                
                self.dismiss(animated: true, completion: nil)
                
                self.delegate?.modifiedName(name: txt)
//                SQLiteHelper.up
//                let count = SQLiteHelper.getAllListData().count
////                if SQLiteHelper.getAllListData().count == 0 {
////                }
//                SQLiteHelper.insertSaveData(priority:count, name:txt)
                

                
            }
            
        }
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
