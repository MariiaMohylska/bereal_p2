//
//  Post.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/30/25.
//
import Foundation
import ParseSwift

struct Post: ParseObject {
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var caption: String?
    var user: Profile?
    var imageFile: ParseFile?
    var location: ParseGeoPoint?
}
