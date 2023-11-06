//
//  OpenAPI+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

import OpenAPIKit

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

extension OpenAPI.Operation: ApiComparable {
    public func compare(to other: OpenAPI.Operation, in context: String? = nil) -> ApiDiff {
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
                security.compare(to: other.security, in: "security"),
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
                identifier.compare(to: other.identifier)
            ]
        )
    }
}

extension OpenAPI.Document.Info.License.Identifier: ApiComparable {
    public func compare(to other: OpenAPI.Document.Info.License.Identifier, in context: String?) -> ApiDiff {
        switch(self, other) {
        case (.spdx(let id1), .spdx(let id2)):
            return id1.compare(to: id2, in: "identifier")
        case (.url(let url1), .url(let url2)):
            return url1.compare(to: url2, in: "url")
        case (.spdx(let id), .url(let url)):
            return .changed(context: "identifier", from: "the identifier \(id)", to: "the url \(url)")
        case (.url(let url), .spdx(let id)):
            return .changed(context: "url", from: "the url \(url)", to: "the identifier \(id)")
        }
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

extension URLTemplate: ApiComparable {
    public func compare(to other: URLTemplate, in context: String? = nil) -> ApiDiff {
        guard self != other else { return .same(context) }

        return .changed(context: context, from: self.absoluteString, to: other.absoluteString)
    }
}

extension OpenAPI.Server: ApiComparable {
    public func compare(to other: OpenAPI.Server, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                urlTemplate.compare(to: other.urlTemplate, in: "URL"),
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
                security.compare(to: other.security, in: "security"),
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

extension OpenAPI.Server: ApiContext {
    public var apiContext: String { urlTemplate.absoluteString }
}

extension OpenAPI.HttpMethod: ApiContext {
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
