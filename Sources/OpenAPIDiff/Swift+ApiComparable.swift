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

        return .changed(context: context, from: String(describing: self), to: String(describing: other))
    }
}

extension URL: ApiComparable {
    public func compare(to other: URL, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .changed(context: context, from: self.absoluteString, to: other.absoluteString)
    }
}

extension Bool: ApiComparable {
    public func compare(to other: Bool, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .changed(context: context, from: String(describing: self), to: String(describing: other))
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

            func candidate() -> Element? {
                if Element.self is Identifiable.Type {
                    return other.first { identitiesMatch($0, element) }
                }
                return offset < other.count ? other[offset] : nil
            }

            guard let otherElement = candidate() else {
                return .removed(elementDescription)
            }

            let comparisonContext = Element.self is Identifiable.Type
                ? elementDescription
                : "\(ordinalStr(offset)) item - " + elementDescription

            return element.compare(to: otherElement, in: comparisonContext)
        } + other
            .filter { element in !self.contains { identitiesMatch($0, element) || $0 == element } }
            .map { .added(String(forContext: $0)) }

        return .init(context: context, changes: changes)
    }
}
