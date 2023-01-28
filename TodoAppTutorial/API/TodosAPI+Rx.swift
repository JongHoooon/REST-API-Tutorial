//
//  TodosAPI+Rx.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/21.
//

import UIKit
import MultipartForm
import RxSwift
import RxCocoa

extension TodosAPI {
    
    /// 모든 할 일 목록 가져오기
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(.notAllowedUrl))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        // 3. API 호출에 대한 응답을 받는다.
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                //                guard let httpResponse = urlResponse as HTTPURLResponse else {
                //
                //                    print("bad status code")
                //                    return .failure(ApiError.unknown(nil))
                //                }
                
                switch urlResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                default:
                    print("default")
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    return .failure(.badStatus(code: urlResponse.statusCode))
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print("topLevelModel:\(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 예외 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return .failure(.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                    return .failure(.decodingError)
                }
                
            })
    }
    
    /// 모든 할 일 목록 가져오기
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        // 3. API 호출에 대한 응답을 받는다.
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                switch urlResponse.statusCode {
                case 401:
                    throw ApiError.unknown(nil)
                    
                default:
                    print("default")
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    throw ApiError.badStatus(code: urlResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print("topLevelModel:\(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 예외 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        throw ApiError.noContent
                    }
                    
                    return listResponse
                } catch {
                    
                    throw ApiError.decodingError
                }
                
            })
    }
    
    /// 특정 할 일 가져오기
    static func fetchATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
//        guard let httpResponse = urlResponse as? HTTPURLResponse else {
//            print("bad status code")
//
//            throw ApiError.unknown(nil)
//            return Observable.error(ApiError.unknown(nil))
//        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        // 3. API 호출에 대한 응답을 받는다.
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                switch urlResponse.statusCode {
                case 401:
                    throw ApiError.unknown(nil)
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                
                if !(200...299).contains(urlResponse.statusCode) {
                    throw ApiError.badStatus(code: urlResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self,
                                         from: data)
                    let todo = baseResponse.data
                    
                    print("baseResponse: \(baseResponse)")
                    print("todo: \(todo)")
                    
                    guard todo != nil else {
                        throw ApiError.noContent
                    }
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
        
    
    /// 할 일 검색하기
    static func searchTodosWithObservable(searchTerm: String,
                                          page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        // 1. urlRequest를 만든다.

        let requestUrl = URL(baesUrl: baseURL + "/todos/search",
                             queryItems: ["query": searchTerm,
                                          "page": "\(page)"])
        
        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = requestUrl else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        //        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        // 3. API 호출에 대한 응답을 받는다.

        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print("topLevelModel:\(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 예외 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        throw ApiError.noContent
                    }
                    
                    return listResponse
                } catch {
                    throw ApiError.decodingError
                }
            })
    }
    
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoWithObservable(title: String,
                                       isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            return .error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form: \(form.contentType)")
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData
        
        // 2. urlSession 으로 API를 호출한다.
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self,
                                         from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    
    static func addATodoJsonWithObservable(title: String,
                                           isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            return .error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = ["title": title,
                                            "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams,
                                                      options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return .error(ApiError.jsonEncoding)
        }
        
        // 2. urlSession 으로 API를 호출한다.
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    static func editTodoJsonWithObservable(id: Int,
                                           title: String,
                                           isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            return .error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = ["title": title,
                                            "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams,
                                                      options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return .error(ApiError.jsonEncoding)
        }
        
        
        // 2. urlSession 으로 API를 호출한다.
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self,
                                         from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    static func editTodoWithObservable(id: Int,
                                       title: String,
                                       isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return .error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title,
                                               "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        // 2. urlSession 으로 API를 호출한다.
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self,
                                         from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    static func deleteATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        print("DEBUG -", #fileID, #function, #line, "- deleteATodo 호출될 / id: \(id)")
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return .error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                    JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title: 제목
    ///   - isDone: 완료 여부
    ///   - completion: 컴플리션 핸들러
    static func addATodoAndFetchTodosWithObservable(title: String,
                                                    isDone: Bool = false) -> Observable<BaseListResponse<Todo>> {
        
        return self.addATodoWithObservable(title: title)
            .flatMapLatest { _ in
                self.fetchTodosWithObservable()
            }
            .share(replay: 1)
    }
        
        self.addATodo(title: title, completion: { result in
            switch result {
            case .success(_):
                self.fetchTodos(completion: {
                    switch $0 {
                    case .success(let data):
                        return
                        completion(.success(data))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                })
            case .failure(let failure):
                completion(.failure(failure))
            }
        })
    }
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithObservable(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        
        let group = DispatchGroup()
        
        // 성공적으로 삭제된거
        var deletedTodoIds: [Int] = [Int]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.deleteATodo(id: aTodoId,
                             completion: { result in
                switch result {
                case .success(let response):
                    
                    // 삭제된 아이디를 배열에 넣는다.
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                    }
                case .failure(let failure):
                    print("inner deleteATodo - failure: \(failure)")
                }
                group.leave()
            }) // 단일 삭제 API 호출
        }
        
        // configure a completion call back
        group.notify(queue: .main) {
            print("모든 api 완료 됨")
            completion(deletedTodoIds)
        }
    }
    
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservable(selectedTodoIds: [Int],
                                                 completion: @escaping (Result<[Todo], ApiError>) -> Void) {
        
        
        let group = DispatchGroup()
        
        // 가져온 할일들
        var fetchedTodos: [Todo] = [Todo]()
        
        // 에러들
        var apiErrors: [ApiError] = []
        
        // 응답 결과들
        var apiResults: [Int: Result<BaseResponse<Todo>, ApiError>] = [:]
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.deleteATodo(id: aTodoId,
                             completion: { result in
                switch result {
                case .success(let response):
                    
                    // 가져온 할을을 배열에 넣는다.
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        
                        print("inner fetchATodo - seccess: \(todo)")
                    }
                case .failure(let failure):
                    print("inner deleteATodo - failure: \(failure)")
                    
                    apiErrors.append(failure)
                }
                group.leave()
            }) // 단일 할일 조회 API 호출
        }
        
        // configure a completion call back
        group.notify(queue: .main) {
            print("모든 api 완료 됨")
            
            // 만약 에러가 있다면 에러 올려주기
            if !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError))
                    return
                }
            }
            
            completion(.success(fetchedTodos))
        }
    }
}
