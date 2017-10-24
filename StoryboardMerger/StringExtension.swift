//
//  StringExtension.swift
//  StoryboardMerger
//
//  Created by Yasmin Benatti on 24/10/17.
//  Copyright © 2017 Flavio Heleno. All rights reserved.
//

import Foundation

extension String {
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var searchRange: Range<String.Index>?
        var count = 0
        while let foundRange = range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
            count += 1
        }
        return count
    }
}
