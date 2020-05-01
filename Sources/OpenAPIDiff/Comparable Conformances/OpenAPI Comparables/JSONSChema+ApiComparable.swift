//
//  JSONSchema+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 4/30/20.
//

import Yams
import OpenAPIKit

extension JSONReference: ApiComparable, Identifiable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        return absoluteString.compare(to: other.absoluteString, in: context)
    }

    public var id: String { absoluteString }
}

extension JSONSchema: ApiComparable {
    public func compare(to other: JSONSchema, in context: String?) -> ApiDiff {
        if self == other {
            return .same(context)
        }

        let encoder = YAMLEncoder()
        encoder.options.sortKeys = true
        let str1 = try! encoder.encode(self)
        let str2 = try! encoder.encode(other)

        if #available(macOS 10.15, *) {
            var orig = str1.split(separator: "\n")
            let new = str2.split(separator: "\n")

            let differences = new
                .difference(from: orig)

            // indent original
            orig = orig.map { "  \($0)" }

            for change in differences {
                switch change {
                case .remove(offset: let offset, element: _, associatedWith: _):
                    let current = orig[offset]
                    orig[offset] = "- \(current.dropFirst(2))" // need to remove indentation applied above
                case .insert(offset: let offset, element: let element, associatedWith: _):
                    let actualOffset = offset + differences.filter { change in
                        guard
                            case .remove(let removalOffset, element: _, associatedWith: _) = change,
                            removalOffset <= offset
                            else {
                                return false
                        }
                        return true
                    }.count

                    orig.insert("+ \(element)", at: actualOffset)
                }
            }

            // truncate large sections without change
            if var idx = orig.indices.last,
                let firstIdx = orig.indices.first {
                var unchangedCount = 0
                while idx >= firstIdx {
                    if orig[idx].starts(with: "  ") && idx > firstIdx {
                        unchangedCount += 1
                    } else {
                        if unchangedCount >= 5 {
                            orig.removeSubrange(orig.index(after: idx)...orig.index(idx, offsetBy: unchangedCount - 1))
                            orig.insert("  [...]", at: orig.index(idx, offsetBy: 1))
                        }

                        unchangedCount = 0
                    }

                    idx = orig.index(before: idx)
                }
            }

            return .init(context: context, diff: .interleaved(diff: orig.joined(separator: "\n")))
        }

        return .changed(context: context, from: str1, to: str2)
    }
}

// MARK: - ApiContext

extension JSONReference: ApiContext {
    public var apiContext: String { absoluteString }
}

extension JSONSchema: ApiContext {
    public var apiContext: String {
        let encoder = YAMLEncoder()
        encoder.options.sortKeys = true
        return try! encoder.encode(self)
    }
}
