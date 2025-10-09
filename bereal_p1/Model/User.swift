//
//  User.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/29/25.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    
    var authData: [String : [String : String]?]?
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
}
