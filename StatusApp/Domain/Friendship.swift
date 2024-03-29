//
//  Friendship.swift
//  StatusApp
//
//  Created by Matthew Parker on 20/11/2022.
//

import Foundation

struct Friendship: Codable {
    var userName: String = ""
    var friendUserName: String = ""
    var accepted: Bool = false
    var areFriends: Bool = false
    var becameFriendsDate: String = ""
    var friendFirstName: String = ""
    var friendLastName: String = ""
    var groupId: UUID
}
