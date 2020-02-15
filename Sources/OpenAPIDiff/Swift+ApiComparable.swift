//
//  Swift+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import Foundation

extension Optional: ApiComparable where Wrapped: ApiComparable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        switch (self, other) {
        case (nil, nil):
            return .same(context)
        case (.some(let left), .some(let right)):
            return left.compare(to: right, in: context)
        case (nil, .some):
            return .added(context)
        case (.some, nil):
            return .removed(context)
        }
    }
}

extension String: ApiComparable {
    public func compare(to other: String, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .init(
            context: context,
            changes: [.changed("from '\(self)' to '\(other)'", diff: [])]
        )
    }
}

extension URL: ApiComparable {
    public func compare(to other: URL, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .init(
            context: context,
            changes: [.changed("from '\(self.absoluteString)' to '\(other.absoluteString)'", diff: [])]
        )
    }
}

extension Bool: ApiComparable {
    public func compare(to other: Bool, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .init(
            context: context,
            changes: [.changed("from \(self) to \(other)", diff: [])]
        )
    }
}

func identitiesMatch(_ left: Any, _ right: Any) -> Bool {
    if let one = left as? Identifiable,
        let two = right as? Identifiable {
        return one.id == two.id
    }
    return false
}

fileprivate func ordinalStr(_ idx: Int) -> String {
    let ordinal = idx + 1
    switch ordinal {
    case 1: return "1st"
    case 2: return "2nd"
    case 3: return "3rd"
    default: return "\(ordinal)th"
    }
}

extension Array: ApiComparable where Element: Equatable, Element: ApiComparable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        let changes: [ApiDiff] = self.enumerated().map { (offset, element) in
            let elementDescription = (element as? ApiContext)?.apiContext ?? String(describing: element)
            guard let otherElement = other.first(where: { identitiesMatch($0, element) }) ?? (offset < other.count ? other[offset] : nil) else {
                return .removed(elementDescription)
            }
            return element.compare(to: otherElement, in: "\(ordinalStr(offset)) item - " + elementDescription)
            } + other
                .filter { element in !self.contains { identitiesMatch($0, element) || $0 == element } }
                .map { .added(String(forContext: $0)) }

        return .init(context: context, changes: changes)
    }
}
