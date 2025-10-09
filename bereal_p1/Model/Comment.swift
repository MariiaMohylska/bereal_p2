//
//  Comment.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 10/3/25.
//

import Foundation
import ParseSwift

struct Comment: ParseObject {
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var author: Profile?
    var comment: String?
    var post: Pointer<Post>?
}
