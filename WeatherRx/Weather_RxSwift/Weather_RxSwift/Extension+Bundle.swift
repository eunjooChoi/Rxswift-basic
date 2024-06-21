//
//  Extension+Bundle.swift
//  Weather_RxSwift
//
//  Created by 최은주 on 6/21/24.
//

import Foundation

extension Bundle {
    var apiKey: String? {
        guard let file = self.path(forResource: "PropertyList", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["API_KEY"] as? String else {
            fatalError("Failed to load API_KEY")
        }
        return key
    }
    
}
