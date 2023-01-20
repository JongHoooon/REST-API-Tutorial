//
//  TodosAPI+Closure.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/18.
//

import UIKit
import MultipartForm

extension TodosAPI {
    /// 모든 할 일 목록 가져오기
    static func fetchTodos(page: Int = 1,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    print("topLevelModel:\(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 예외 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(.noContent))
                    }
                
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    /// 특정 할 일 가져오기
    static func fetchATodo(id: Int,
                           completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    /// 할 일 검색하기
    static func searchTodos(searchTerm: String,
                           page: Int = 1,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
//        let urlString = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        let requestUrl = URL(baesUrl: baseURL + "/todos/search",
                             queryItems: ["query": searchTerm,
                                          "page": "\(page)"])
        
        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = requestUrl else {
            return completion(.failure(.notAllowedUrl))
        }
          
//        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    print("topLevelModel:\(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 예외 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(.noContent))
                    }
                
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodo(title: String,
                         isDone: Bool = false,
                         completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
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
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
        
    static func addATodoJson(title: String,
                             isDone: Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
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
            return completion(.failure(.jsonEncoding))
        }
        
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }

    static func editTodoJson(id: Int,
                             title: String,
                             isDone: Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
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
            return completion(.failure(.jsonEncoding))
        }
        
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    static func editTodo(id: Int,
                         title: String,
                         isDone: Bool = false,
                         completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title,
                                            "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    static func deleteATodo(id: Int,
                           completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        print("DEBUG -", #fileID, #function, #line, "- deleteATodo 호출될 / id: \(id)")
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try
                        JSONDecoder().decode(BaseResponse<Todo>.self,
                                             from: jsonData)
                
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
    
    
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title: 제목
    ///   - isDone: 완료 여부
    ///   - completion: 컴플리션 핸들러
    static func addATodoAndFetchTodos(title: String,
                                      isDone: Bool = false,
                                      completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        self.addATodo(title: title, completion: { result in
            switch result {
            case .success(_):
                self.fetchTodos(completion: {
                    switch $0 {
                    case .success(let data):
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
    static func deleteSelectedTodos(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        
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
    static func fetchSelectedTodos(selectedTodoIds: [Int],
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
