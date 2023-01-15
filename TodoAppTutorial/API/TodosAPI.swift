//
//  TodosAPI.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/16.
//

import Foundation

enum TodosAPI {
//    static let baseURL: String = {
//        return
//    }
    
    static let version = "v1"
    
    #if DEBUG // 디버그
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
    #else // 릴리즈
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
    #endif
    
    enum ApiError: Error {
        case parsingError
        case noContent
        case decodingError
        case badStatus(code: Int)
    }
    
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<TodosResponse, ApiError>) -> Void) {
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다.
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let jsonData = data {
                do {
                    // JSON -> Struct로 변경 즉 디코딩 즉 데이터 파싱
                    let todosResponse = try JSONDecoder().decode(TodosResponse.self, from: jsonData)
                    let modelObjects = todosResponse.data
                    print("topLevelModel:\(todosResponse.data)")
                    completion(.success(todosResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
        // 3. API 호출에 대한 응답을 받는다.
    }
}
