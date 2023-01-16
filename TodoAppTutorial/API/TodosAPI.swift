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
        case noContent
        case decodingError
        case unauthorized
        case badStatus(code: Int)
        case unknown(_ error: Error?)
        
        var info: String {
            switch self {
            case .noContent:            return "데이터가 없습니다."
            case .decodingError:        return "디코딩 에러입니다."
            case .unauthorized:         return "인증되지 않은 사용자 입니다.."
            case let .badStatus(code):  return "에러 상태코드: \(code)"
            case .unknown(let error):   return "알 수 없는 에러입니다.\n\(String(describing: error))"
            }
        }
    }
    
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        
        
        // 1. urlRequest를 만든다.
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        let url = URL(string: urlString)!
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
}
