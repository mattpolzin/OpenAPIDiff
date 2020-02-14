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

// MARK - Entrypoint
if CommandLine.arguments.count < 3 {
    print("Exactly two arguments are required. Both must be valid file paths to OpenAPI files in either YAML or JSON format.")

    exit(1)
}

let left = URL(fileURLWithPath: CommandLine.arguments[1])
let right = URL(fileURLWithPath: CommandLine.arguments[2])

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

print(api1.compare(to: api2).description(drillingDownWhere: { !$0.isSame }))
