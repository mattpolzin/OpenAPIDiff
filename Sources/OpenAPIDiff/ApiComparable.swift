import Foundation
import OpenAPIKit

public protocol ApiComparable {
    func compare(to other: Self, in context: String?) -> ApiDiff
}
