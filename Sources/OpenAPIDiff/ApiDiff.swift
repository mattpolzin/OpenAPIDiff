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

    public var isSame: Bool {
        switch diff {
        case .same:
            return true
        case .removed, .added, .updated, .interleaved, .changed:
            return false
        }
    }

    public enum Diff: Equatable, Comparable {
        case same
        case removed
        case added
        case updated(from: String, to: String)
        case interleaved(diff: String)
        indirect case changed([ApiDiff])

        public static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.same, .removed), (.same, .added), (.same, .updated), (.same, .interleaved), (.same, .changed(_)):
                return true
            case (.removed, .added), (.removed, .updated), (.removed, .interleaved), (.removed, .changed):
                return true
            case (.added, .updated), (.added, .interleaved), (.added, .changed):
                return true
            case (.updated, .interleaved), (.updated, .changed):
                return true
            case (.interleaved, .changed):
                return true
            case (.changed(let diffs1), .changed(let diffs2)):
                return diffs1.lexicographicallyPrecedes(diffs2)
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
        case .updated(from: let old, to: let new):
            return "Updated\(contextString) from '\(old)' to '\(new)'"
        case .interleaved(diff: let diffString):
            return "Changed\(contextString) \n" + diffString
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

// MARK: - Convenience
extension ApiDiff {
    public static let same: Self = .init(context: nil, diff: .same)

    public static func same(_ context: String? = nil) -> Self { .init(context: context, diff: .same) }

    public static let added: Self = .init(context: nil, diff: .added)

    public static func added(_ context: String? = nil) -> Self { .init(context: context, diff: .added) }

    public static let removed: Self = .init(context: nil, diff: .removed)

    public static func removed(_ context: String? = nil) -> Self { .init(context: context, diff: .removed) }

    public static func changed(context: String?, from: String, to: String) -> Self { .init(context: context, diff: .updated(from: from, to: to)) }

    public static func changed(_ context: String? = nil, diff: [ApiDiff]) -> Self { .init(context: context, diff: .changed(diff)) }
}

// MARK: - Markdown
extension ApiDiff {
    public func markdownDescription(drillingDownWhere diffFilter: (ApiDiff) -> Bool = { _ in true }) -> String {
        return markdownDescription(drillingDownWhere: diffFilter, depth: 1)
    }

    private func nestedNode(_ diffs: [ApiDiff], drillingDownWhere diffFilter: (ApiDiff) -> Bool, depth: Int) -> String {
        let headerPrefix = "\n" + String(repeating: "#", count: depth)
        let contextString = context.map { " \($0)" } ?? ""

        let nestedDiff = diffs.count == 0
            ? ""
            : "\n" + diffs.map { diff in
                diff.markdownDescription(drillingDownWhere: diffFilter, depth: depth + 1)
            }.joined(separator: "\n")

        return headerPrefix + " Changes to\(contextString)" + nestedDiff
    }

    /// Takes a nested diff array that is shallow and one dimensional enough and flattens it.
    /// Otherwise, it leaves it nested.
    private func flattenedLeafNode(_ apiDiff: ApiDiff, drillingDownWhere diffFilter: (ApiDiff) -> Bool, depth: Int) -> String {
        let diff = apiDiff.diff
        guard
            case .changed(let changes) = diff,
            changes.filter(diffFilter).count == 1,
            let childChange = changes.filter(diffFilter).first,
            let childContext = apiDiff.context,
            let context = self.context
        else {
            return nestedNode([apiDiff], drillingDownWhere: diffFilter, depth: depth)
        }
        let headerPrefix = "\n" + String(repeating: "#", count: depth)
        return headerPrefix + " Changes to \(context) -> \(childContext)" + "\n"
            + childChange.markdownDescription(drillingDownWhere: diffFilter, depth: depth + 1)
    }

    private func markdownDescription(drillingDownWhere diffFilter: (ApiDiff) -> Bool, depth: Int) -> String {

        let contextString = context.map { " \($0)" } ?? ""
        switch diff {
        case .same:
            return "- No Difference to\(contextString)"
        case .added:
            return "- Added\(contextString)"
        case .removed:
            return "- Removed\(contextString)"
        case .updated(from: let old, to: let new):
            let contextString = context.map { " `\($0)`" } ?? ""
            return "- Updated\(contextString) from"
                + "\n > " + old.replacingOccurrences(of: "\n", with: "\n > ")
                + "\n\n- to"
                + "\n > " + new.replacingOccurrences(of: "\n", with: "\n > ")
        case .interleaved(diff: let diffString):
            let contextString = context.map { " `\($0)`" } ?? ""
            return "- Updated\(contextString) "
                + "\n\n```diff\n"
                + diffString
                + "\n```\n"
        case .changed(let diffs):
            let filteredDiffs = diffs.filter(diffFilter)

            if filteredDiffs.count == 1, let diff = filteredDiffs.first {
                return flattenedLeafNode(diff, drillingDownWhere: diffFilter, depth: depth)
            } else {
                return nestedNode(filteredDiffs, drillingDownWhere: diffFilter, depth: depth)
            }
        }
    }
}
