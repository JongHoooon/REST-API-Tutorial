//
//  TodosAPI+Combine.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/02/05.
//


import UIKit
import MultipartForm
import RxSwift
import RxCocoa
import Combine
import CombineExt

extension TodosAPI {
    
    /// 모든 할 일 목록 가져오기
    static func fetchTodosWithPublisherResult(page: Int = 1) -> AnyPublisher<Result<BaseListResponse<Todo>, ApiError>, Never> {
        
        // 1. urlRequest 를 만든다
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Just(.failure(ApiError.notAllowedUrl)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) -> Result<BaseListResponse<Todo>, ApiError> in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                do {
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return .failure(ApiError.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                    // decoding error
                    return .failure(ApiError.decodingError)
                }
            })
//            .catch({ err in
//                return Just(.failure(.unknown(nil)))
//            })
            .replaceError(with: .failure(ApiError.unknown(nil)))
//            .assertNoFailure()  // 실패가 나지않을거다! 만약 error발생하면 crash
            .eraseToAnyPublisher()
    }
    
    /// 모든 할 일 목록 가져오기
    static func fetchTodosWithPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
            })
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let todos = response.data, !todos.isEmpty else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError { // ApiError 라면
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    /// 특정 할 일 가져오기
    static func fetchATodoWithPublisher(id: Int) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, urlResponse: URLResponse) -> Data in
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
                        
                    default: print("default")
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode){
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                    
                    return data
            }
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap { response in // 상태 코드는 200인데 파싱한 데이터에 따라서 에러 처리
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            }
            .mapError { err -> ApiError in
                if let error = err as? ApiError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            }
            .eraseToAnyPublisher()
    }
    
    /// 할 일 검색하기
    static func searchTodosWithPublisher(searchTerm: String, page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm,
                                                                              "page" : "\(page)"])
        
        guard let url = requestUrl else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let todos = response.data, !todos.isEmpty else {
                    throw ApiError.noContent
                }
                return response
            }
            .mapError { err -> ApiError in
                if let error = err as? ApiError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                return ApiError.unknown(nil)
            }
            .eraseToAnyPublisher()
    }
        
        
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoWithPublisher(title: String,
                                       isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form.contentType : \(form.contentType)")
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    /// 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithPublisher(title: String,
                                          isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            return Fail(error: ApiError.jsonEncoding).eraseToAnyPublisher()
        }
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    /// 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodoJsonWithPublisher(id: Int,
                                           title: String,
                                           isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            return Fail(error: ApiError.jsonEncoding).eraseToAnyPublisher()
        }
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError { // ApiError 라면
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
            
    
    /// 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodoWithPublisher(id: Int,
                                       title: String,
                                       isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : String] = ["title": title, "is_done" : "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError { // ApiError 라면
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    /// 할 일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답결과
    static func deleteATodoWithPublisher(id: Int) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: ApiError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
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
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode){
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard response.data != nil else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ err -> ApiError in
                if let error = err as? ApiError { // ApiError 라면
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    
    /// 할일 추가 -> 모든 할일 가져오기 - 에러 함께
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithPublisher(title: String,
                                                    isDone: Bool = false) -> AnyPublisher<[Todo], ApiError> {
        
        // 1
        return self.addATodoWithPublisher(title: title)
            .flatMap({ _ in
                self.fetchTodosWithPublisher()
            })
            .compactMap { $0.data } // [Todo]
//            .catch({ err in
//                print("TodosAPI - catch : err : \(err)")
//                return Just([]).eraseToAnyPublisher()
//            })
//            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    /// 할일 추가 -> 모든 할일 가져오기 - No 에러
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithPublisherNoError(title: String,
                                                    isDone: Bool = false) -> AnyPublisher<[Todo], Never> {
        
        // 1
        return self.addATodoWithPublisher(title: title)
            .flatMap({ _ in
                self.fetchTodosWithPublisher()
            })
            .compactMap { $0.data } // [Todo]
//            .catch({ err in
//                print("TodosAPI - catch : err : \(err)")
//                return Just([]).eraseToAnyPublisher()
//            })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithPublisherMerge(selectedTodoIds: [Int]) -> AnyPublisher<Int, Never> {
        
        // 매개변수 배열 -> Observable 스트림 배열로 만들어준다.
        
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id } // Int?
                .replaceError(with: nil) 
                .eraseToAnyPublisher()
        }
        
        return Publishers
            .MergeMany(apiCallPublishers)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    
    static func deleteSelectedTodosWithPublisherZip(selectedTodoIds: [Int]) -> AnyPublisher<[Int], Never> {
        
        // 매개변수 배열 -> Observable 스트림 배열로 만들어준다.
        
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id } // Int?
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return apiCallPublishers
            .zip()
            .map { $0.compactMap{ $0 } }
            .eraseToAnyPublisher()
    }
     
    static func deleteSelectedTodosWithPublisherMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        // 매개변수 배열 -> Observable 스트림 배열로 만들어준다.
        
        let apiCallOBservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallOBservables)
            .compactMap { $0 }
        
        //        return Observable.zip(apiCallOBservables)
        //            .map { // Observable<[Int?]>
        //            $0.compactMap { $0 }
        //            }
    }
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> Observable<[Todo]> {
        
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchATodoWithObservable(id: id)
                .map { $0.data }
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables)
            .map { $0.compactMap { $0 } }
    }
}
