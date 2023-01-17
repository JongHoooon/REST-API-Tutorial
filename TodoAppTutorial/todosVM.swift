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
        
        TodosAPI.deleteATodo(id: 2035, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let aTodoResponse):
                print("TodosVM - addATodo - aTodoResponse: \(aTodoResponse)")
            case .failure(let failure):
                print("TodosVM - addATodo - failure: \(failure)")
                self.handleError(failure)
                self.handleError2(failure)
            }
        })
        
//        TodosAPI.searchTodos(searchTerm: "빡코딩") { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//                self.handleError2(failure)
//            }
//        }
        
//        TodosAPI.fetchATodo(id: 1500, completion: { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//                self.handleError2(failure)
//            }
//        })
        
//        TodosAPI.fetchTodos { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//                self.handleError2(failure)
//            }
//        }
    } // init
    
    private func handleError2(_ error: Error) {
        guard let apiError = error as? TodosAPI.ApiError else {
            print("api handle 오류")
            return
        }
        print(apiError.info)
        
        switch apiError {
        case .noContent:
            print("컨텐츠 없음")
        case .unauthorized:
            print("인증 안됨")
        case .badStatus(let code):
            print("bad status \(code)")
        default:
            print("default")
        }
    }
    
    
    /// API 에러처리
    /// - Parameter error: API 에러
    private func handleError(_ error: Error) {
        if error is TodosAPI.ApiError {
            let apiError = error as! TodosAPI.ApiError
            
            print("handleError: Error: \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증 안됨")
            case .badStatus(let code):
                print("bad status \(code)")
            default:
                print("default")
            }
        }
    }
}
