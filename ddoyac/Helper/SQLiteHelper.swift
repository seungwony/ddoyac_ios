//
//  SQLiteHelper.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import Foundation
import SQLite3

func openDatabase() -> OpaquePointer? {
    var db: OpaquePointer? = nil
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("ddoyac.sqlite")
    
    
    if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(fileURL.path)")
        return db
    } else {
        print("Unable to open database. Verify that you created the directory described " +
            "in the Getting Started section.")
        
    }
    return nil
}



class SQLiteHelper {
    
    
    
    
    class func createMainTable() {
        
      
       
        let db = openDatabase()
        
        let createTableString = "CREATE TABLE IF NOT EXISTS saved_list (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, priority INTEGER, created DATE)"
        // 1
        var createTableStatement: OpaquePointer? = nil
        // 2
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            // 3
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("saved_list table created.")
                
            } else {
                print("saved_list table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        // 4
        sqlite3_finalize(createTableStatement)

        sqlite3_close(db)
    
    }
    
    
    class func createRelTable() {
    
        
        let db = openDatabase()
       
        
        
        let createTableString = "CREATE TABLE IF NOT EXISTS saved_drug (id INTEGER, rel_id INTEGER, priority INTEGER, created DATE)"
        // 1
        var createTableStatement: OpaquePointer? = nil
        // 2
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            // 3
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("saved_drug table created.")
                
            } else {
                print("saved_drug table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        // 4
        sqlite3_finalize(createTableStatement)

        sqlite3_close(db)
    
    }
    
    
    
    class func initialInsert() {
        
        
        let db = openDatabase()
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO saved_list (name, priority, created) VALUES (?, ?, ?);"
         


        
        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
      
            let name = "기본 저장 목록"
            let now = Date().timeIntervalSince1970
            
            sqlite3_bind_text(insertStatement, 1, strdup(name), -1, nil)
            
            sqlite3_bind_int(insertStatement, 2, 0)
            
            
            sqlite3_bind_double(insertStatement, 3, now)
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
        
        sqlite3_close(db)
    }


    class func insertSaveData(priority:Int, name:String) {
        let db = openDatabase()
        
        let now = Date().timeIntervalSince1970
        
        
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO saved_list (priority, name, created) VALUES (?, '\(name)', '\(now)');"
         


        
        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            // 2
            sqlite3_bind_int(insertStatement, 1, Int32(priority))
            // 3
            sqlite3_bind_text(insertStatement, 2, strdup(name), -1, nil)
            sqlite3_bind_double(insertStatement, 3, now)
            
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
        
        sqlite3_close(db)
    }

    
    
    class  func insertDrugData(id:Int, rel_id:Int, priority:Int) {
        let db = openDatabase()
        
        let now = Date().timeIntervalSince1970
        
        
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO saved_drug (id, rel_id, priority, created) VALUES (?, ?, ?, ?);"
         


        
        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            // 2
            sqlite3_bind_int(insertStatement, 1, Int32(id))
            sqlite3_bind_int(insertStatement, 2, Int32(rel_id))
            sqlite3_bind_int(insertStatement, 3, Int32(priority))
            
//            sqlite3_bind_text(insertStatement, 4, now, -1, nil)
            sqlite3_bind_double(insertStatement, 4, now)
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
        
        sqlite3_close(db)
    }
    
    
     
    class func getAllListData() -> [SavedModel]{
        
        let db = openDatabase()
        
        var savedList:[SavedModel] = []
        let queryStatementString = "SELECT * FROM saved_list ORDER BY priority DESC;"
        
      var queryStatement: OpaquePointer?
      if sqlite3_prepare_v2(
        db,
        queryStatementString,
        -1,
        &queryStatement,
        nil
      ) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          let id = sqlite3_column_int(queryStatement, 0)
          
            
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
            print("Query result is nil.")
            return []
          }
            let name = String(cString: queryResultCol1)
            
            let priority = sqlite3_column_int(queryStatement, 2)
            
            guard let queryResultCol3 = sqlite3_column_text(queryStatement, 3) else {
            print("Query result is nil.")
            return []
          }
            
            let created = String(cString: queryResultCol3)
          
          print("Query Result:")
          print("\(id) | \(priority) | \(name) | \(created)")
            
            let saveModel = SavedModel(id: Int(id), priority: Int(priority), name: name, created: created)
            
            savedList.append(saveModel)
        }
      } else {
          let errorMessage = String(cString: sqlite3_errmsg(db))
          print("\nQuery is not prepared \(errorMessage)")
      }
      sqlite3_finalize(queryStatement)
        
        sqlite3_close(db)
        return savedList
    }


    class func getRelDrugData(id:Int, rel_id:Int) -> [Int]{
        let db = openDatabase()
        var savedDrugIds:[Int] = []
        let queryStatementString = "SELECT * FROM saved_drug WHERE id = \(id) AND rel_id = \(rel_id);"
        
      var queryStatement: OpaquePointer?
      if sqlite3_prepare_v2(
        db,
        queryStatementString,
        -1,
        &queryStatement,
        nil
      ) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          let rel_id = sqlite3_column_int(queryStatement, 1)
          
            savedDrugIds.append(Int(rel_id))
        }
      } else {
          let errorMessage = String(cString: sqlite3_errmsg(db))
          print("\nQuery is not prepared \(errorMessage)")
      }
      sqlite3_finalize(queryStatement)
        sqlite3_close(db)
        
        return savedDrugIds
    }
    
    
    
    class func getAllDrugDataById(id:Int) -> [Int]{
        let db = openDatabase()
        var savedDrugIds:[Int] = []
        let queryStatementString = "SELECT * FROM saved_drug WHERE id = \(id) ORDER BY created DESC;"
        
      var queryStatement: OpaquePointer?
      if sqlite3_prepare_v2(
        db,
        queryStatementString,
        -1,
        &queryStatement,
        nil
      ) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          let rel_id = sqlite3_column_int(queryStatement, 1)
          
            savedDrugIds.append(Int(rel_id))
        }
      } else {
          let errorMessage = String(cString: sqlite3_errmsg(db))
          print("\nQuery is not prepared \(errorMessage)")
      }
      sqlite3_finalize(queryStatement)
        sqlite3_close(db)
        
        return savedDrugIds
    }

    
    
    class func deleteData(id:Int) {
        let db = openDatabase()
      var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM saved_list WHERE id = \(id);"
      if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
          print("\nSuccessfully deleted row.")
        } else {
          print("\nCould not delete row.")
        }
      } else {
        print("\nDELETE statement could not be prepared")
      }
      
      sqlite3_finalize(deleteStatement)
        sqlite3_close(db)
    }
    
    
    class func deleteDrugData(id:Int) {
        let db = openDatabase()
      var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM saved_drug WHERE id = \(id);"
      if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
          print("\nSuccessfully deleted row.")
        } else {
          print("\nCould not delete row.")
        }
      } else {
        print("\nDELETE statement could not be prepared")
      }
      
      sqlite3_finalize(deleteStatement)
        sqlite3_close(db)
    }
    
    class func deleteDrugDataWithRel(id:Int, rel_id:Int) {
        let db = openDatabase()
      var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM saved_drug WHERE id = \(id) AND rel_id \(rel_id);"
      if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
          print("\nSuccessfully deleted row.")
        } else {
          print("\nCould not delete row.")
        }
      } else {
        print("\nDELETE statement could not be prepared")
      }
      
      sqlite3_finalize(deleteStatement)
        sqlite3_close(db)
    }
    
    
    
     
   class func updateSavedListName(id:Int, name:String) {
        let db = openDatabase()
        let updateStatementString = "UPDATE saved_list SET name = '\(name)' WHERE id = \(id);"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
        sqlite3_close(db)
    }
     

}
