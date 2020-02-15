//
//  OpenAPI+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import OpenAPIKit

extension JSONReference: ApiComparable, Identifiable {
    public func compare(to other: Self, in context: String? = nil) -> ApiDiff {
        return description.compare(to: other.description, in: context)
    }

    public var id: String { description }
}

extension OpenAPI.PathItem.Parameter: ApiComparable, Identifiable {
    public func compare(to other: OpenAPI.PathItem.Parameter, in context: String? = nil) -> ApiDiff {
        // TODO: finish writing differ
        return .init(
            context: context,
            changes: [
                name.compare(to: other.name, in: "name"),
                // parameterLocation.compare(to: other.parameterLocation, in: "parameter location"),
                description.compare(to: other.description, in: "description"),
                deprecated.compare(to: other.deprecated, in: "deprecated"),
                // schemaOrContent.compare(to: other.schemaOrContent, in: "schema or content")
            ]
        )
    }

    public var id: String { name }
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
                // externalDocs.compare(to: other.externalDocs, in: "external docs"),
                operationId.compare(to: other.operationId, in: "operation ID"),
                parameters.compare(to: other.parameters, in: "parameters"),
                // requestBody.compare(to: other.requestBody, in: "request body"),
                // responses.compare(to: other.responses, in: "responses"),
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

extension OpenAPI.Document.Info: ApiComparable {
    public func compare(to other: OpenAPI.Document.Info, in context: String?) -> ApiDiff {
        // TODO: finish differ
        return .init(
            context: context,
            changes: [
                title.compare(to: other.title, in: "title"),
                description.compare(to: other.description, in: "description"),
//                termsOfService.compare(to: other.termsOfService, in: "terms of service"),
//                contact.compare(to: other.contact, in: "contact info"),
//                license.compare(to: other.license, in: "license"),
                version.compare(to: other.version, in: "API version")
            ]
        )
    }
}

extension OpenAPI.ExternalDoc: ApiComparable {
    public func compare(to other: OpenAPI.ExternalDoc, in context: String?) -> ApiDiff {
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

extension OpenAPI.Document: ApiComparable {
    public func compare(to other: OpenAPI.Document, in context: String? = nil) -> ApiDiff {
        // TODO: finish differ
        return .init(
            context: context ?? "Document",
            changes: [
                openAPIVersion.compare(to: other.openAPIVersion, in: "OpenAPI Spec Version"),
                info.compare(to: other.info, in: "info"),
                servers.compare(to: other.servers, in: "servers"),
                paths.compare(to: other.paths, in: "paths"),
//                components.compare(to: other.components, in: "components"),
//                security.compare(to: other.security, in: security),
//                tags.compare(to: other.tags, in: "tags"),
                externalDocs.compare(to: other.externalDocs, in: "external docs")
            ]
        )
    }
}

// MARK: - ApiContext
extension OpenAPI.PathComponents: ApiContext {
    public var apiContext: String { "**\(rawValue)**" }
}

extension OpenAPI.PathItem.Parameter: ApiContext {
    public var apiContext: String {
        "\(required ? "_required_ " : "")`\(name)`"
    }
}

extension OpenAPI.HttpVerb: ApiContext {
    public var apiContext: String { "`\(rawValue)`" }
}

extension JSONReference: ApiContext {
    public var apiContext: String { description }
}
