//
//  Profile.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation
import RealmSwift

class Profile: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var email: String?
    @objc dynamic var name: String?
        
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "authId", email, name
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        email = try? container.decodeIfPresent(String.self, forKey: .email)
        
        let realm = try Realm()
        
        if realm.isInWriteTransaction {
            realm.add(self, update: .modified)
        } else {
            try realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(email, forKey: .email)
    }
}
