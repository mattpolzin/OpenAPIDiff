//
//  Either+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import OpenAPIKit

extension Either: ApiComparable where A: ApiComparable, B: ApiComparable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        switch (self, other) {
        case (.a(let left), .a(let right)):
            return left.compare(to: right, in: context)
        case (.b(let left), .b(let right)):
            return left.compare(to: right, in: context)
        case (.a(let left as ApiContext), .b(let right as ApiContext)),
             (.b(let left as ApiContext), .a(let right as ApiContext)):
            return .changed(
                context: context,
                from: String(describingContext: left),
                to: String(describingContext: right)
            )
        case (.a(let left), .b(let right)):
            return .changed(
                context: context,
                from: String(describing: left),
                to: String(describing: right)
            )
        case (.b(let left), .a(let right)):
            return .changed(
                context: context,
                from: String(describing: left),
                to: String(describing: right)
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
            return String(describingContext: val)
        case .b(let val):
            return String(describingContext: val)
        }
    }
}
