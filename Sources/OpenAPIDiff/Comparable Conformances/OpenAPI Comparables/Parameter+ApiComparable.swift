//
//  Parameter+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 4/30/20.
//

import OpenAPIKit

extension OpenAPI.PathItem.Parameter.Context: ApiComparable {
    public func compare(to other: OpenAPI.PathItem.Parameter.Context, in context: String?) -> ApiDiff {
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

extension OpenAPI.PathItem.Parameter: ApiComparable, Identifiable {
    public func compare(to other: OpenAPI.PathItem.Parameter, in context: String? = nil) -> ApiDiff {
        // TODO: finish writing differ
        return .init(
            context: context,
            changes: [
                self.name.compare(to: other.name, in: "name"),
                self.required.compare(to: other.required, in: "required"),
                self.context.compare(to: other.context, in: "parameter location"),
                self.description.compare(to: other.description, in: "description"),
                self.deprecated.compare(to: other.deprecated, in: "deprecated"),
                self.schemaOrContent.compare(to: other.schemaOrContent, in: "schema or content")
            ]
        )
    }

    public var id: String { name }
}

// MARK: - ApiContext

extension OpenAPI.PathItem.Parameter: ApiContext {
    public var apiContext: String {
        "\(required ? "_required_ " : "")`\(name)`"
    }
}

extension OpenAPI.PathItem.Parameter.Context: ApiContext {
    public var apiContext: String {
        return location.rawValue
    }
}
