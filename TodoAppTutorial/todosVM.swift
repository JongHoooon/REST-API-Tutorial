//
//  todosVM.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/16.
//

import Foundation
import Combine

class TodosVM: ObservableObject {
    
    init() {
        print("DEBUG -", #fileID, #function, #line)
        TodosAPI.fetchTodos { result in
            switch result {
            case .success(let todosResponse):
                print("TodosVM - todosResponse: \(todosResponse)")
            case .failure(let failure):
                print("TodosVM - failure: \(failure)")
            }
        }
    }
}
