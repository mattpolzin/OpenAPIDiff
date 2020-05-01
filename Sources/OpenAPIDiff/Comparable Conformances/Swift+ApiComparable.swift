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

        func element(_ element: Element, in other: Self, atIndex index: Int) -> Element? {
            if Element.self is Identifiable.Type {
                return other.first { identitiesMatch($0, element) }
            }
            return index < other.count ? other[index] : nil
        }

        let changes: [ApiDiff] = self.enumerated().map { (offset, currentElement) in
            let elementDescription = String(describingContext: currentElement)

            func candidate() -> Element? {
                return element(currentElement, in: other, atIndex: offset)
            }

            guard let otherElement = candidate() else {
                return .removed(elementDescription)
            }

            let comparisonContext = Element.self is Identifiable.Type
                ? elementDescription
                : "\(ordinalStr(offset)) item\(elementDescription.isEmpty ? "" : " - " + elementDescription)"

            return currentElement.compare(to: otherElement, in: comparisonContext)
        } + other
            .enumerated()
            .filter { (offset, currentElement) in
                return element(currentElement, in: self, atIndex: offset) == nil
            }
            .map { .added(String(describingContext: $0.element)) }

        return .init(context: context, changes: changes)
    }
}

extension Dictionary: ApiComparable where Value: ApiComparable, Key: ApiContext {
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

// MARK: - ApiContext

extension Dictionary: ApiContext {
    public var apiContext: String { "" }
}
