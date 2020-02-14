import Foundation
import OpenAPIKit
import OrderedDictionary
import Poly

public protocol ApiComparable {
    func compare(to other: Self, in context: String?) -> ApiDiff
}
