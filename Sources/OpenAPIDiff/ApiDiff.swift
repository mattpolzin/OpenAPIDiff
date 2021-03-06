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
        case .removed, .added, .genericChanged, .updated, .interleaved, .changed:
            return false
        }
    }

    public var additions: Int {
        switch diff {
        case .same, .removed, .genericChanged, .updated, .interleaved:
            return 0
        case .added:
            return 1
        case .changed(let diffs):
            return diffs.reduce(0, { $0 + $1.additions })
        }
    }

    public var removals: Int {
        switch diff {
        case .same, .added, .genericChanged, .updated, .interleaved:
            return 0
        case .removed:
            return 1
        case .changed(let diffs):
            return diffs.reduce(0, { $0 + $1.removals })
        }
    }

    /// Changes, excluding additions and removals, which can be retrieved
    /// from their own accessors.
    public var changes: Int {
        switch diff {
        case .same, .added, .removed:
            return 0
        case .genericChanged, .updated, .interleaved:
            return 1
        case .changed(let diffs):
            return diffs.reduce(0, { $0 + $1.changes })
        }
    }

    public enum Diff: Equatable, Comparable {
        case same
        case removed
        case added
        case genericChanged // changed with no details provided
        case updated(from: String, to: String)
        case interleaved(diff: String)
        indirect case changed([ApiDiff])

        public static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.same, .removed), (.same, .added), (.same, .genericChanged), (.same, .updated), (.same, .interleaved), (.same, .changed(_)):
                return true
            case (.removed, .added), (.removed, .genericChanged), (.removed, .updated), (.removed, .interleaved), (.removed, .changed):
                return true
            case (.added, .genericChanged), (.added, .updated), (.added, .interleaved), (.added, .changed):
                return true
            case (.genericChanged, .updated), (.genericChanged, .interleaved), (.genericChanged, .changed):
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
        case .genericChanged:
            return "Changed\(contextString)"
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
    public var markdownDescription: String {
        return markdownDescription(drillingDownWhere: { _ in true })
    }

    public func markdownDescription(drillingDownWhere diffFilter: (ApiDiff) -> Bool, attemptFlatteningPast flattenDepth: Int = 4) -> String {
        return markdownDescription(drillingDownWhere: diffFilter, depth: 1, attemptFlatteningPast: flattenDepth)
    }

    private func nestedNode(_ diffs: [ApiDiff], drillingDownWhere diffFilter: (ApiDiff) -> Bool, depth: Int, flattenDepth: Int) -> String {
        let headerPrefix = "\n" + String(repeating: "#", count: depth)
        let contextString = context.map { " \($0)" } ?? ""

        let nestedDiff = diffs.count == 0
            ? ""
            : "\n" + diffs.map { diff in
                diff.markdownDescription(drillingDownWhere: diffFilter, depth: depth + 1, attemptFlatteningPast: flattenDepth)
            }.joined(separator: "\n")

        return headerPrefix + " Changes to\(contextString)" + nestedDiff
    }

    /// Takes a nested diff array that is shallow and one dimensional enough and flattens it.
    /// Otherwise, it leaves it nested.
    private static func flattenedDiff(_ apiDiff: ApiDiff, drillingDownWhere diffFilter: (ApiDiff) -> Bool) -> ApiDiff {

        func _extendedContext(for apiDiff: ApiDiff, in context: String? = nil) -> (String, next: Diff?) {

            let parentContext = context ?? apiDiff.context ?? ""
            let childContext = context != nil ? apiDiff.context.map { " → \($0)" } ?? "" : ""

            switch apiDiff.diff {
            case .changed(let changes) where changes.filter(diffFilter).count <= 1:
                let filteredChanges = changes.filter(diffFilter)
                guard let change = filteredChanges.first else {
                    return (parentContext + childContext, nil)
                }
                return _extendedContext(for: change, in: parentContext + childContext)

            default:
                return (parentContext + childContext, apiDiff.diff)
            }
        }

        let extendedContext = _extendedContext(for: apiDiff)

        // If we've flattened all of the way to a leaf node, just return a generic change
        guard let nextDiff = extendedContext.next else {
            return .init(context: extendedContext.0, diff: .genericChanged)
        }

        // Otherwise, process nested changes
        return .init(context: extendedContext.0, diff: nextDiff)
    }

    private func markdownDescription(drillingDownWhere diffFilter: (ApiDiff) -> Bool, depth: Int, attemptFlatteningPast flattenDepth: Int) -> String {

        let contextString = context.map { " \($0)" } ?? ""
        switch diff {
        case .same:
            return "- No Difference to\(contextString)"
        case .added:
            return "- Added\(contextString)"
        case .genericChanged:
            return "- Changed\(contextString)"
        case .removed:
            return "- Removed\(contextString)"
        case .updated(from: let old, to: let new):
            let contextString = context.map { " **\($0)**" } ?? ""
            return "- Updated\(contextString) "
                + "\n\n _from_ ↯"
                + "\n > " + old.replacingOccurrences(of: "\n", with: "\n > ")
                + "\n\n _to_ ↯"
                + "\n > " + new.replacingOccurrences(of: "\n", with: "\n > ")
                + "\n"
        case .interleaved(diff: let diffString):
            let contextString = context.map { " **\($0)**" } ?? ""
            return "- Updated\(contextString) "
                + "\n\n```diff\n"
                + diffString
                + "\n```\n"
        case .changed(let diffs):
            let filteredDiffs = diffs.filter(diffFilter)

            guard filteredDiffs.count > 0 else {
                return "- Changes to\(contextString)"
            }

            let flattenedDiffs: [ApiDiff]
            if depth >= flattenDepth {
                flattenedDiffs = filteredDiffs.map { Self.flattenedDiff($0, drillingDownWhere: diffFilter) }.sorted()
            } else {
                flattenedDiffs = filteredDiffs
            }

            return nestedNode(flattenedDiffs, drillingDownWhere: diffFilter, depth: depth, flattenDepth: flattenDepth)
        }
    }
}
