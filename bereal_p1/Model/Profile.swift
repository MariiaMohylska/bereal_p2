//
//  Profile.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 10/4/25.
//

import Foundation
import ParseSwift

struct Profile: ParseObject {
    var user: Pointer<User>?
    var firstName: String?
    var lastName: String?
    var lastUpdated: Date?
    
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
}
