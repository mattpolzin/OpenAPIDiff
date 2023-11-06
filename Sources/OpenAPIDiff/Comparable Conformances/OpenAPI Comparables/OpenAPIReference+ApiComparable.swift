//
//  OpenAPIReference+ApiComparable.swift
//  
//
//  Created by Mathew Polzin on 12/25/22.
//

import OpenAPIKit

extension OpenAPI.Reference: ApiComparable {
    public func compare(to other: OpenAPIKit.OpenAPI.Reference<ReferenceType>, in context: String?) -> ApiDiff {
        return .init(
            context: context,
            changes: [
                jsonReference.compare(to: other.jsonReference),
                summary.compare(to: other.summary),
                description.compare(to: other.description)
            ]
        )
    }
}
