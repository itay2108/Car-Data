//
//  TaskMonitor.swift
//  Car Data
//
//  Created by itay gervash on 07/06/2022.
//

import Foundation
import Alamofire

class CDTaskMonitor {
    static let main = CDTaskMonitor()
    
    private var activeTasks: [CDTask] = []
    
    func add(activeTask task: CDTask) {
        activeTasks.append(task)
    }
    
    func remove(activeTask task: CDTask) {
        activeTasks.removeAll(where: { $0.id == task.id})
    }
    
    func remove(activeTasksWithID id: String) {
        activeTasks.removeAll(where: {$0.id == id})
    }
    
    func cancel(activeTask task: CDTask) {
        for activeTask in activeTasks {
            if activeTask.id == task.id {
                activeTask.request.cancel()
                remove(activeTask: activeTask)
            }
        }
    }
    
    func cancel(activeTasksWithRequest request: DataRequest) {
        for activeTask in activeTasks {
            if activeTask.request == request {
                activeTask.request.cancel()
                remove(activeTask: activeTask)
            }
        }
    }
    
    func cancel(activeTasksWithId id: String) {
        for activeTask in activeTasks {
            if activeTask.id == id {
                activeTask.request.cancel()
                remove(activeTask: activeTask)
            }
        }
    }
    
    func cancelAllTasks() {
        for activeTask in activeTasks {
            activeTask.request.cancel()
        }
        activeTasks.removeAll()
    }
}
