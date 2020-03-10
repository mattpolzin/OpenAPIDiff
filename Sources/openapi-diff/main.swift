//
//  main.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import Foundation
import OpenAPIKit
import OpenAPIDiff
import Yams
import ArgumentParser

struct OpenAPIDiff: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Print the differences between two OpenAPI Documents.",
        discussion: "By default a custom nested structure is printed to show the differences between the two OpenAPI documents. While this format can be concise and good for quick information, the Markdown file produced when passing the --markdown flag is a better deliverable."
        )

    @Argument()
    var firstFilePath: String

    @Argument()
    var secondFilePath: String

    enum PrintStyle: String, CaseIterable {
        case plaintext
        case markdown
        case stats
    }

    @Flag(
        name: .shortAndLong,
        default: .plaintext,
        help: .init(
            "Print the diff as nested plaintext, a markdown document, or just print stats.",
            discussion: "Only plaintext and markdown printouts are affected by the --skip-schemas option. Stats always prints unfiltered numbers."
        )
    )
    var printStyle: PrintStyle

    @Flag(
        name: [.customLong("skip-schemas")],
        help: .init(
            "Don't compare OpenAPI Schema Objects.",
            discussion: "By default, schemas will be diffed. This can produce lengthy diffs and might be distracting from the more salient points of the diff."
        )
    )
    var skipSchemaDiffs: Bool

    func run() throws {
        let left = URL(fileURLWithPath: firstFilePath)
        let right = URL(fileURLWithPath: secondFilePath)

        let api1: OpenAPI.Document
        let api2: OpenAPI.Document

        if left.pathExtension.lowercased() == "json" {
            let file1 = try! Data(contentsOf: left)
            let file2 = try! Data(contentsOf: right)

            api1 = try! JSONDecoder().decode(OpenAPI.Document.self, from: file1)
            api2 = try! JSONDecoder().decode(OpenAPI.Document.self, from: file2)
        } else {
            let file1 = try! String(contentsOf:  left)
            let file2 = try! String(contentsOf: right)

            api1 = try! YAMLDecoder().decode(OpenAPI.Document.self, from: file1)
            api2 = try! YAMLDecoder().decode(OpenAPI.Document.self, from: file2)
        }

        let filter: (ApiDiff) -> Bool = { apiDiff in
            let filters: [(ApiDiff) -> Bool] = [
                { !$0.isSame },
                self.skipSchemaDiffs ? { $0.context != "schema" } : nil
            ].compactMap { $0 }

            return filters.allSatisfy { $0(apiDiff) }
        }

        // Just print the differences to stdout
        let comparison = api1.compare(to: api2)
        let description: String
        switch printStyle {
        case .plaintext:
            description = comparison.description(drillingDownWhere: filter)
        case .markdown:
            description = comparison.markdownDescription(drillingDownWhere: filter)
        case .stats:
            description = """
    \(comparison.additions) additions.
    \(comparison.removals) removals.
    \(comparison.changes) changes.
"""
        }
        print(description)
    }
}

OpenAPIDiff.main()
