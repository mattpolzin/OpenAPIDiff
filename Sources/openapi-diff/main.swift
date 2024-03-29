//
//  main.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import Foundation
import OpenAPIKit
import OpenAPIKit30
import OpenAPIKitCompat
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

    enum PrintStyle: String, EnumerableFlag {
        case plaintext
        case markdown
        case stats
    }

    @Flag(
        help: .init(
            "Print the diff as nested plaintext, a markdown document, or just print stats.",
            discussion: "Only plaintext and markdown printouts are affected by the --skip-schemas option. Stats always prints unfiltered numbers."
        )
    )
    var printStyle: PrintStyle = .plaintext

    @Flag(
        name: [.customLong("skip-schemas")],
        help: .init(
            "Don't compare OpenAPI Schema Objects.",
            discussion: "By default, schemas will be diffed. This can produce lengthy diffs and might be distracting from the more salient points of the diff."
        )
    )
    var skipSchemaDiffs: Bool = false

    func run() throws {
        let left = URL(fileURLWithPath: firstFilePath)
        let right = URL(fileURLWithPath: secondFilePath)

        let api1V3: OpenAPIKit30.OpenAPI.Document?
        let api2V3: OpenAPIKit30.OpenAPI.Document?
        let api1: OpenAPIKit.OpenAPI.Document
        let api2: OpenAPIKit.OpenAPI.Document

        if left.pathExtension.lowercased() == "json" {
            let file1 = try! Data(contentsOf: left)
            let file2 = try! Data(contentsOf: right)

            api1V3 = try? JSONDecoder().decode(OpenAPI.Document.self, from: file1)
            api1 = api1V3?.convert(to: .v3_1_0) ??
                (try! JSONDecoder().decode(OpenAPI.Document.self, from: file1))
            api2V3 = try? JSONDecoder().decode(OpenAPI.Document.self, from: file2)
            api2 = api2V3?.convert(to: .v3_1_0) ??
                (try! JSONDecoder().decode(OpenAPI.Document.self, from: file2))
        } else {
            let file1 = try! String(contentsOf:  left)
            let file2 = try! String(contentsOf: right)

            api1V3 = try? YAMLDecoder().decode(OpenAPI.Document.self, from: file1)
            api1 = api1V3?.convert(to: .v3_1_0) ??
                (try! YAMLDecoder().decode(OpenAPI.Document.self, from: file1))
            api2V3 = try? YAMLDecoder().decode(OpenAPI.Document.self, from: file2)
            api2 = api2V3?.convert(to: .v3_1_0) ??
                (try! YAMLDecoder().decode(OpenAPI.Document.self, from: file2))
        }

        let filter: (ApiDiff) -> Bool = { apiDiff in
            let filters: [(ApiDiff) -> Bool] = [
                { !$0.isSame },
                self.skipSchemaDiffs ? { $0.context != ("schema" as String?) } : nil
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
