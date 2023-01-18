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
}
