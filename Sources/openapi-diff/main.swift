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

var args = CommandLine.arguments.dropFirst()

let printMarkdown: Bool
if args.contains("--markdown") {
    printMarkdown = true
    args.removeAll { $0 == "--markdown" }
} else {
    printMarkdown = false
}

let printSchemaDiffs: Bool
if args.contains("--skip-schemas") {
    printSchemaDiffs = false
    args.removeAll { $0 == "--skip-schemas" }
} else {
    printSchemaDiffs = true
}

// MARK - Entrypoint
if args.count < 2 {
    print("Exactly two arguments are required. Both must be valid file paths to OpenAPI files in either YAML or JSON format.")

    exit(1)
}

let left = URL(fileURLWithPath: args.removeFirst())
let right = URL(fileURLWithPath: args.removeFirst())

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
        printSchemaDiffs ? nil : { $0.context != "schema" }
        ].compactMap { $0 }

    return filters.allSatisfy { $0(apiDiff) }
}

// Just print the differences to stdout
let comparison = api1.compare(to: api2)
print(
    printMarkdown
        ? comparison.markdownDescription(drillingDownWhere: filter)
        : comparison.description(drillingDownWhere: filter)
)
