//
//  Item.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var price: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
