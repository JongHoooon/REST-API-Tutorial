//
//  TodosResponse.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/16.
//

import Foundation

struct TodosResponse: Decodable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
//    let makeError: String
}

struct BaseListResponse<T: Decodable>: Decodable {
    let data: [T]?
    let meta: Meta?
    let message: String?
//    let makeError: String
}

struct BaseResponse<T: Decodable>: Decodable {
    let data: T?
    let message: String?
//    let code: String?
}

struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

