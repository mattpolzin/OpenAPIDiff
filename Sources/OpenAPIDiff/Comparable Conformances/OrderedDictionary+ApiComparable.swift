//
//  OrderedDictionary+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import OpenAPIKit

extension OrderedDictionary: ApiComparable where Value: ApiComparable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        let changes: [ApiDiff] = self.map { (key, value) in
            let keyString = String(describingContext: key)
            guard let otherValue = other[key] else {
                return .removed(keyString)
            }
            return value.compare(to: otherValue, in: keyString)
            } + other
                .filter { (key, value) in self[key] == nil }
                .map { .added(String(describingContext: $0.key)) }

        return .init(
            context: context,
            changes: changes
        )
    }
}
