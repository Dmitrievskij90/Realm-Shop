//
//  String+Extension.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 27.06.2021.
//

import UIKit

extension String {
    static func roundedNumber (_ number: Double) -> String {
        let number = "Total price:\(String(format: "%.2f", number))$"
        return number
    }
}
