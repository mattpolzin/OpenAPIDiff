//
//  Either+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import Poly

extension Either: ApiComparable where A: ApiComparable, A: ApiContext, B: ApiComparable, B: ApiContext {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        switch (self, other) {
        case (.a(let left), .a(let right)):
            return left.compare(to: right, in: context)
        case (.b(let left), .b(let right)):
            return left.compare(to: right, in: context)
        case (.a(let left as ApiContext), .b(let right as ApiContext)),
             (.b(let left as ApiContext), .a(let right as ApiContext)):
            return .init(
                context: context,
                changes: [.changed("from '\(String(forContext: left))' to '\(String(forContext: right))'", diff: [])]
            )
        }
    }
}

extension Either: Identifiable where A: Identifiable, B: Identifiable {
    public var id: String {
        switch self {
        case .a(let val):
            return val.id
        case .b(let val):
            return val.id
        }
    }
}

extension Either: ApiContext {
    public var apiContext: String {
        switch self {
        case .a(let val):
            return String(forContext: val)
        case .b(let val):
            return String(forContext: val)
        }
    }
}
