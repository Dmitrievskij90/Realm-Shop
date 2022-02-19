//
//  Category.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: Int = 0
    let items = List<Item>()
    let categoryBackground = [0x94D0CC, 0xEEC4C4, 0x9FE6A0, 0xF1CA89, 0xCE97B0, 0x907FA4, 0xF7A440, 0xFFCC29]
}
