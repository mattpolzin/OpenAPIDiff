//
//  ApiDiff.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import Foundation

public struct ApiDiff: CustomStringConvertible, Equatable, Comparable {
    public let context: String?
    public let diff: Diff

    public init(context: String? = nil, diff: Diff) {
        self.context = context
        self.diff = diff
    }

    /// Create an API Diff with the given changes.
    /// The result will either be `.changed` with the given
    /// changes or `.same` if the array of changes is empty
    /// or only contains `.same` entries..
    public init(context: String? = nil, changes diffs: [ApiDiff]) {
        self.context = context

        let trueDiffs = diffs.filter { !$0.isSame }

        if trueDiffs.isEmpty {
            self.diff = .same
        } else {
            self.diff = .changed(diffs.sorted())
        }
    }

    public static let same: Self = .init(context: nil, diff: .same)
    public static func same(_ context: String? = nil) -> Self { .init(context: context, diff: .same) }
    public static let added: Self = .init(context: nil, diff: .added)
    public static func added(_ context: String? = nil) -> Self { .init(context: context, diff: .added) }
    public static let removed: Self = .init(context: nil, diff: .removed)
    public static func removed(_ context: String? = nil) -> Self { .init(context: context, diff: .removed) }
    public static func changed(_ context: String? = nil, diff: [ApiDiff]) -> Self { .init(context: context, diff: .changed(diff)) }

    public var isSame: Bool {
        switch diff {
        case .same:
            return true
        case .removed, .changed, .added:
            return false
        }
    }

    public enum Diff: Equatable, Comparable {
        case removed
        case same
        indirect case changed([ApiDiff])
        case added

        public static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.removed, .same), (.removed, .changed), (.removed, .added):
                return true
            case (.same, .changed), (.same, .added):
                return true
            case (.changed, .added):
                return true
            default:
                return false
            }
        }
    }

    public var description: String {
        return description(drillingDownWhere: { _ in true })
    }

    public func description(drillingDownWhere diffFilter: (ApiDiff) -> Bool) -> String {
        let contextString = context.map { " \($0)" } ?? ""
        switch diff {
        case .same:
            return "No Difference to\(contextString)"
        case .added:
            return "Added\(contextString)"
        case .removed:
            return "Removed\(contextString)"
        case .changed(let diffs):
            let filteredDiffs = diffs.filter(diffFilter)
            let nestedDiff = filteredDiffs.count == 0
                ? ""
                : "\n| " + filteredDiffs.map { diff in
                    diff.description(drillingDownWhere: diffFilter)
                        .split(separator: "\n")
                        .joined(separator: "\n| ")
                }.joined(separator: "\n| ")

            return "Changed\(contextString)" + nestedDiff
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.diff == rhs.diff && lhs.context != nil && rhs.context != nil
            ? lhs.context! < rhs.context!
            : lhs.diff < rhs.diff
    }
}
