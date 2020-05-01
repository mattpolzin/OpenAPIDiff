//
//  SecurityScheme+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 4/30/20.
//

import OpenAPIKit

extension OpenAPI.OAuthFlows: ApiComparable {
    public func compare(to other: OpenAPI.OAuthFlows, in context: String?) -> ApiDiff {
        guard self != other else {
            return .init(context: context, changes: [])
        }

        // TODO: implement
        return .changed(context, diff: [])
    }
}

extension OpenAPI.SecurityScheme.SecurityType: ApiComparable {
    public func compare(to other: OpenAPI.SecurityScheme.SecurityType, in context: String?) -> ApiDiff {
        switch (self, other) {
        case (.apiKey(let name1, let location1), .apiKey(let name2, let location2)):
            return .init(
                context: context,
                changes: [
                    name1.compare(to: name2),
                    location1.rawValue.compare(to: location2.rawValue)
                ]
            )
        case (.http(let scheme1, let bearerFormat1), .http(let scheme2, let bearerFormat2)):
            return .init(
                context: context,
                changes: [
                    scheme1.compare(to: scheme2),
                    bearerFormat1.compare(to: bearerFormat2)
                ]
            )
        case (.oauth2(let flows1), .oauth2(let flows2)):
            return .init(
                context: context,
                changes: [
                    flows1.compare(to: flows2, in: "oauth2")
                ]
            )
        case (.openIdConnect(let url1), .openIdConnect(let url2)):
            return .init(
                context: context,
                changes: [
                    url1.compare(to: url2)
                ]
            )
        default:
            return .changed(context: context, from: name, to: other.name)
        }
    }
}

extension OpenAPI.SecurityScheme.SecurityType {
    var name: String {
        switch self {
        case .apiKey:
            return "apiKey"
        case .http:
            return "http"
        case .oauth2:
            return "oauth2"
        case .openIdConnect:
            return "openIdConnect"
        }
    }
}

extension OpenAPI.SecurityScheme: ApiComparable {
    public func compare(to other: OpenAPI.SecurityScheme, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                type.compare(to: other.type, in: "details"),
                description.compare(to: other.description, in: "description")
            ]
        )
    }
}

// MARK: - ApiContext

extension OpenAPI.SecurityScheme.Location: ApiContext {
    public var apiContext: String { rawValue }
}
