//
//  HotList.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import Foundation

// MARK: - PurpleData
struct PurpleData: Codable {
    let data: [Datum]
    let paging: Paging
    let summary: Summary
}

// MARK: - Datum
struct Datum: Codable {
    let id, name: String
    let duration: Int
    let url: String
    let trackNumber: Int
    let explicitness: Bool
    let availableTerritories: [String]
    let album: Album
    
    enum CodingKeys: String, CodingKey {
        case id, name, duration, url
        case trackNumber = "track_number"
        case explicitness
        case availableTerritories = "available_territories"
        case album
    }
}

// MARK: - Album
struct Album: Codable {
    let id, name: String
    let url: String
    let explicitness: Bool
    let availableTerritories: [String]
    let releaseDate: String
    let images: [Image]
    let artist: Artist
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, explicitness
        case availableTerritories = "available_territories"
        case releaseDate = "release_date"
        case images, artist
    }
}

// MARK: - Artist
struct Artist: Codable {
    let id, name: String
    let url: String
    let images: [Image]
}

// MARK: - Image
struct Image: Codable {
    let height, width: Int
    let url: String
}

// MARK: - Paging
struct Paging: Codable {
    let offset, limit: Int
    let next: String
    let previosu: JSONNull?  //當offset 為0 時 就為 null 。
}

// MARK: - Summary
struct Summary: Codable {
    let total: Int
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
