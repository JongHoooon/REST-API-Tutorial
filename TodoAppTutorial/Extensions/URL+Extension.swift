//
//  URL+Extension.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/16.
//

import Foundation

extension URL {
    
    init?(baesUrl: String, queryItems: [String: String]) {
        
        guard var urlComponents = URLComponents(string: baesUrl) else { return nil }
        
        urlComponents.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalUrlString = urlComponents.url?.absoluteString else { return nil }
        self.init(string: finalUrlString)
    }
}