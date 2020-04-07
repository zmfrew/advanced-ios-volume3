//
//  ReminderGroup.swift
//  Project6
//
//  Created by Paul Hudson on 03/08/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import Foundation

struct ReminderGroup: Codable {
    var name: String
    var items: [Reminder]
}
