//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskList: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete<T: Object>(_ data: T) {
        write {
            if let taskList = data as? TaskList {
                realm.delete(taskList.tasks)
                realm.delete(taskList)
            } else if let task = data as? Task {
                realm.delete(task)
            }
        }
    }
    
    func edit<T: Object>(_ data: T, newValue: String, withNote note: String? = nil) {
        write {
            if let taskList = data as? TaskList {
                taskList.name = newValue
            } else if let task = data as? Task {
                task.name = newValue
                task.note = note ?? ""
            }
        }
    }

    func done<T: Object>(_ data: T, isComplete: Bool) {
        write {
            if let taskList = data as? TaskList {
                taskList.tasks.setValue(isComplete, forKey: "isComplete")
            } else if let task = data as? Task {
                task.setValue(isComplete, forKey: "isComplete")
            }
        }
    }

    // MARK: - Tasks
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [task, note])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
