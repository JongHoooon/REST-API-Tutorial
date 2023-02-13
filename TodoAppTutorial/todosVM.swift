//
//  todosVM.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/16.
//

import Foundation
import Combine
import RxSwift

class TodosVM: ObservableObject {
    
    var disposeBag = DisposeBag()
    
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        print("DEBUG -", #fileID, #function, #line)
        
        Task {
            let response = await TodosAPI.fetchTodosWithAsync()
            print("fetchTodosWithAsyncResult: response \(response)")
        }
        
        
        TodosAPI.deleteSelectedTodosWithPublisherZip(selectedTodoIds: [2342, 2343, 2344])
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let failure):
                    self.handleError(failure)
                case .finished:
                    print("TodosVM - finished")
                }
            }, receiveValue: { response in
                print("TodosVM - response: \(response)")
            })
            .store(in: &subscriptions)
        
//        TodosAPI.addATodoAndFetchTodosWithPublisherNoError(title: "추추추ㄹㅇㄹㄹㅇ가")
//            .sink(receiveCompletion: { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions)
        
//        TodosAPI.fetchTodosWithPublisher()
//            .sink(receiveCompletion: { [weak self] completion in
//                guard let self = self else { return }
//
//                switch completion {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions)
        
        
//            .sink { response in
//                switch result {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .success(let baseListTodoResponse):
//                    print("TodosVM - fetchTodosWithPublisherResult : baseListTodoResponse : \(baseListTodoResponse)")
//                }
//            }
//            .store(in: &subscriptions)
        
        
//        TodosAPI.fetchSelectedTodosWithObservable(selectedTodoIds: [2299, 2242])
//            .subscribe(onNext: { todos in
//                print("TodosVM - fetchSelectedTodosWithObservable : response : \(todos)")
//            })
//            .disposed(by: self.disposeBag)
//
//        TodosAPI.deleteSelectedTodosWithObservableMerge(selectedTodoIds: [2255, 2253])
//            .subscribe(onNext: { deletedTodo in
//                print("TodosVM - deleteSelectedTodosWithObservable : response : \(deletedTodo)")
//            }, onError: { err in
//                print("TodosVM - deleteSelectedTodosWithObservable : err : \(err)")
//            })
//            .disposed(by: self.disposeBag)
        
//        TodosAPI.deleteSelectedTodosWithObservable(selectedTodoIds: [2256, 2258])
//            .subscribe(onNext: { deletedTodos in
//                print("TodosVM - deleteSelectedTodosWithObservable : response : \(deletedTodos)")
//            }, onError: { err in
//                print("TodosVM - deleteSelectedTodosWithObservable : err : \(err)")
//            })
//            .disposed(by: self.disposeBag)
        
//        TodosAPI.addATodoAndFetchTodosWithObservable(title: "할일 추가하기") // [Todo]
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (response : [Todo]) in
//                print("TodosVM - addATodoAndFetchTodosWithObservable : response : \(response)")
//            }).disposed(by: disposeBag)
        
        
//            .catch({ err in
//                print("TodosVM - catch : err : \(err)")
//                return Observable.just([])
//            })
//            .subscribe(onNext: { [weak self] (response: [Todo] in
//                print("TodoVM - fetchTodosWithObservable: response: \(response)")
//            ), onError: { } })
        
        
        
//        TodosAPI.fetchATodoWithObservable(id: 2111)
//            .observe(on: MainScheduler.instance)
//            .compactMap { $0.data }
//            .catch({ error in
//                
//                print("TodosVM - catch: error: \(error)")
//                ㄱㄷ
//            })
        
        
//            .subscribe(onNext: { [weak self] (response: BaseResponse<Todo>) in
//                print("TodosVM - fetchATodoWithObservable : response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
//
        
        
//        TodosAPI.fetchTodosWithObservable()
//            .observe(on: MainScheduler.instance)
//            .compactMap { $0.data }
//            .catch({ err in
//                print("TodosVM - catch : err: \(err)")
//
//
//                return .just([])
//            })
//            .subscribe(onNext: { [weak self] (response: [Todo]) in
//                print("TodosVM - fetchTodosWithObservable : response: \(response)")
//            })
//            .disposed(by: disposeBag)
    
        
//        TodosAPI.fetchTodosWithObservable()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (response: BaseListResponse<Todo>) in
//                print("TodosVM - fetchTodosWithObservable : response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.fetchTodosWithObservableResult()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//
//                switch result {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .success(let response):
//                    print("TodosVM - fetchTodosWithObservable : response: \(response)")
//                }
//            })
//            .disposed(by: disposeBag)
        
        
//        TodosAPI.fetchSelectedTodos(selectedTodoIds: [2068], completion: { result in
//            switch result {
//            case .success(let data):
//                print("TodosVM - fetchSelectedTodos : data: \(data)")
//            case .failure(let failure):
//                print("TodosVM - fetchSelectedTods : failure: \(failure)")
//            }
//        })
        
//        TodosAPI.deleteSelectedTodos(selectedTodoIds: [2038, 2090, 2089],
//                                     completion: { [weak self] deletedTodos in
//
//            print("TodosVM - deleteSelectedTodos: \(deletedTodos)")
//
//        })
        
//        TodosAPI.addATodoAndFetchTodos(title: "연쇄ㄹㄹㄹ",
//                                       completion: { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let todolistResponse):
//                print("TodosVM - todolist response: \(todolistResponse)")
//            case .failure(let error):
//                print("failure")
//                self.handleError(error)
//            }
//        })
        
//        TodosAPI.deleteATodo(id: 2030, completion: { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM - addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM - addATodo - failure: \(failure)")
//                self.handleError(failure)
//                self.handleError2(failure)
//            }
//        })
        
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
            case .decodingError:
                print("DEBUG - Decoding Error, \(#fileID), \(#function), \(#line)")
            default:
                print("default")
            }
        }
    }
}


