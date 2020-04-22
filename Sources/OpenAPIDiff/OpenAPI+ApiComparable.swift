//
//  OpenAPI+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import OpenAPIKit
import Yams

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

extension OpenAPI.PathItem.Parameter.Location: ApiComparable {
    public func compare(to other: OpenAPI.PathItem.Parameter.Location, in context: String?) -> ApiDiff {
        if self == other {
            return .same(context)
        }
        return .changed(context: context, from: apiContext, to: other.apiContext)
    }
}

extension OpenAPI.PathItem.Parameter.Schema: ApiComparable {
    public func compare(to other: OpenAPI.PathItem.Parameter.Schema, in context: String?) -> ApiDiff {
        // TODO: finish writing differ
        return .init(
            context: context,
            changes: [
//                style.compare(to: other.style, in: "style"),
                explode.compare(to: other.explode, in: "explode"),
                allowReserved.compare(to: other.allowReserved, in: "allow reserved"),
                schema.compare(to: other.schema, in: "schema")
            ]
        )
    }
}

extension OpenAPI.Content: ApiComparable {
    public func compare(to other: OpenAPI.Content, in context: String?) -> ApiDiff {
        // TODO: write differ
        return .init(
            context: context,
            changes: [
                schema.compare(to: other.schema, in: "schema"),
//                example.compare(to: other.example, in: "example"),
//                examples.compare(to: other.examples, in: "examples"),
//                encoding.compare(to: other.encoding, in: "encoding")
            ]
        )
    }
}

extension OpenAPI.PathItem.Parameter: ApiComparable, Identifiable {
    public func compare(to other: OpenAPI.PathItem.Parameter, in context: String? = nil) -> ApiDiff {
        // TODO: finish writing differ
        return .init(
            context: context,
            changes: [
                name.compare(to: other.name, in: "name"),
                required.compare(to: other.required, in: "required"),
                 parameterLocation.compare(to: other.parameterLocation, in: "parameter location"),
                description.compare(to: other.description, in: "description"),
                deprecated.compare(to: other.deprecated, in: "deprecated"),
                schemaOrContent.compare(to: other.schemaOrContent, in: "schema or content")
            ]
        )
    }

    public var id: String { name }
}

extension OpenAPI.Response: ApiComparable {
    public func compare(to other: OpenAPI.Response, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                description.compare(to: other.description, in: "description"),
//                headers.compare(to: other.headers, in: "headers"),
                content.compare(to: other.content, in: "content")
            ]
        )
    }
}

extension OpenAPI.Request: ApiComparable {
    public func compare(to other: OpenAPI.Request, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                description.compare(to: other.description, in: "description"),
                content.compare(to: other.content, in: "content"),
                required.compare(to: other.required, in: "required")
            ]
        )
    }
}

extension OpenAPI.PathItem.Operation: ApiComparable {
    public func compare(to other: OpenAPI.PathItem.Operation, in context: String? = nil) -> ApiDiff {
        // TODO: finish writing differ
        return .init(
            context: context,
            changes: [
                tags.compare(to: other.tags, in: "tags"),
                summary.compare(to: other.summary, in: "summary"),
                description.compare(to: other.description, in: "description"),
                externalDocs.compare(to: other.externalDocs, in: "external docs"),
                operationId.compare(to: other.operationId, in: "operation ID"),
                parameters.compare(to: other.parameters, in: "parameters"),
                requestBody.compare(to: other.requestBody, in: "request body"),
                responses.compare(to: other.responses, in: "responses"),
                deprecated.compare(to: other.deprecated, in: "deprecated"),
                // security.compare(to: other.security, in: "security"),
                servers.compare(to: other.servers, in: "servers")
            ]
        )
    }
}

extension OpenAPI.PathItem: ApiComparable {
    public func compare(to other: OpenAPI.PathItem, in context: String? = nil) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                summary.compare(to: other.summary, in: "summary"),
                description.compare(to: other.description, in: "description"),
                servers.compare(to: other.servers, in: "servers"),
                parameters.compare(to: other.parameters, in: "parameters"),
                get.compare(to: other.get, in: "GET endpoint"),
                put.compare(to: other.put, in: "PUT endpoint"),
                post.compare(to: other.post, in: "POST endpoint"),
                delete.compare(to: other.delete, in: "DELETE endpoint"),
                options.compare(to: other.options, in: "OPTIONS endpoint"),
                head.compare(to: other.head, in: "HEAD endpoint"),
                patch.compare(to: other.patch, in: "PATCH endpoint"),
                trace.compare(to: other.trace, in: "TRACE endpoint")
            ]
        )
    }
}

extension OpenAPI.Document.Version: ApiComparable {
    public func compare(to other: OpenAPI.Document.Version, in context: String?) -> ApiDiff {
        return rawValue.compare(to: other.rawValue, in: context)
    }
}

extension OpenAPI.Document.Info.Contact: ApiComparable {
    public func compare(to other: OpenAPI.Document.Info.Contact, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                name.compare(to: other.name, in: "name"),
                url.compare(to: other.url, in: "URL"),
                email.compare(to: other.email, in: "email")
            ]
        )
    }
}

extension OpenAPI.Document.Info.License: ApiComparable {
    public func compare(to other: OpenAPI.Document.Info.License, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                name.compare(to: other.name, in: "name"),
                url.compare(to: other.url, in: "URL")
            ]
        )
    }
}

extension OpenAPI.Document.Info: ApiComparable {
    public func compare(to other: OpenAPI.Document.Info, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                title.compare(to: other.title, in: "title"),
                description.compare(to: other.description, in: "description"),
                termsOfService.compare(to: other.termsOfService, in: "terms of service"),
                contact.compare(to: other.contact, in: "contact info"),
                license.compare(to: other.license, in: "license"),
                version.compare(to: other.version, in: "API version")
            ]
        )
    }
}

extension OpenAPI.ExternalDocumentation: ApiComparable {
    public func compare(to other: OpenAPI.ExternalDocumentation, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                description.compare(to: other.description, in: "description"),
                url.compare(to: other.url, in: "URL")
            ]
        )
    }
}

extension OpenAPI.Server.Variable: ApiComparable {
    public func compare(to other: OpenAPI.Server.Variable, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                `enum`.compare(to: other.enum, in: "enum"),
                `default`.compare(to: other.default, in: "default"),
                description.compare(to: other.description, in: "description")
            ]
        )
    }
}

extension OpenAPI.Server: ApiComparable {
    public func compare(to other: OpenAPI.Server, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                url.compare(to: other.url, in: "URL"),
                description.compare(to: other.description, in: "description"),
                variables.compare(to: other.variables, in: "variables")
            ]
        )
    }
}

extension OpenAPI.Tag: ApiComparable {
    public func compare(to other: OpenAPI.Tag, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                name.compare(to: other.name, in: "name"),
                description.compare(to: other.description, in: "description"),
                externalDocs.compare(to: other.externalDocs, in: "external docs")
            ]
        )
    }
}

extension OpenAPI.Document: ApiComparable {
    public func compare(to other: OpenAPI.Document, in context: String? = nil) -> ApiDiff {
        // TODO: finish differ
        return .init(
            context: context ?? apiContext,
            changes: [
                openAPIVersion.compare(to: other.openAPIVersion, in: "OpenAPI Spec Version"),
                info.compare(to: other.info, in: "info"),
                servers.compare(to: other.servers, in: "servers"),
                paths.compare(to: other.paths, in: "paths"),
//                components.compare(to: other.components, in: "components"),
//                security.compare(to: other.security, in: security),
                tags.compare(to: other.tags, in: "tags"),
                externalDocs.compare(to: other.externalDocs, in: "external docs")
            ]
        )
    }
}

// MARK: - ApiContext
extension OpenAPI.Path: ApiContext {
    public var apiContext: String { "**\(rawValue)**" }
}

extension OpenAPI.PathItem.Parameter: ApiContext {
    public var apiContext: String {
        "\(required ? "_required_ " : "")`\(name)`"
    }
}

extension OpenAPI.PathItem.Parameter.Location: ApiContext {
    public var apiContext: String {
        switch self {
        case .query: return "query"
        case .header: return "header"
        case .path: return "path"
        case .cookie: return "cookie"
        }
    }
}

extension OpenAPI.Server: ApiContext {
    public var apiContext: String { url.absoluteString }
}

extension OpenAPI.HttpVerb: ApiContext {
    public var apiContext: String { "`\(rawValue)`" }
}

extension OpenAPI.Response.StatusCode: ApiContext {
    public var apiContext: String { "status code \(rawValue)" }
}

extension OpenAPI.ContentType: ApiContext {
    public var apiContext: String { rawValue }
}

extension OpenAPI.Document: ApiContext {
    public var apiContext: String { info.title }
}

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
