//
//  ApiContext.swift
//  
//
//  Created by Mathew Polzin on 2/13/20.
//

/// An ApiContext can describe itself contextually for the purposes of the diff.
/// This is really just `CustomStringConvertible` except it does not collide
/// with existing conformances to that protocol or with other meanings for a
/// `description` property.
public protocol ApiContext {
    var apiContext: String { get }
}

extension String {
    init(forContext ctx: Any) {
        self = (ctx as? ApiContext)?.apiContext ?? String(describing: ctx)
    }
}
