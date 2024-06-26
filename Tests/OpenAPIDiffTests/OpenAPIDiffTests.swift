import XCTest
import OpenAPIKit
import OpenAPIDiff

final class OpenAPIDiffTests: XCTestCase {
    func test_arrayAddition() {
        let before = ["hello"]
        let after = ["hello", "world"]

        let comparison = before.compare(to: after)

        XCTAssertEqual(comparison.diff, .changed([.same("1st item - hello"), .added("world")]))

        let before2 = ["hello"]
        let after2 = ["world", "hello"]

        let comparison2 = before2.compare(to: after2)

        XCTAssertEqual(comparison2.diff, .changed([.added("hello"), .changed(context: "1st item - hello", from: "hello", to: "world")]))
    }

    func test_arrayRemoval() {
        let before = ["hello", "world"]
        let after = ["hello"]

        let comparison = before.compare(to: after)

        XCTAssertEqual(comparison.diff, .changed([.same("1st item - hello"), .removed("world")]))

        let before2 = ["hello", "world"]
        let after2 = ["world"]

        let comparison2 = before2.compare(to: after2)

        XCTAssertEqual(comparison2.diff, .changed([.removed("world"), .changed(context: "1st item - hello", from: "hello", to: "world")]))
    }

    func test_arrayReplace() {
        let before = ["hello", "world"]
        let after = ["hello", "there"]

        let comparison = before.compare(to: after)

        XCTAssertEqual(comparison.diff, .changed([.same("1st item - hello"), .changed(context: "2nd item - world", from: "world", to: "there")]))

        let before2 = ["hello", "world"]
        let after2 = ["big", "world"]

        let comparison2 = before2.compare(to: after2)

        XCTAssertEqual(comparison2.diff, .changed([.same("2nd item - world"), .changed(context: "1st item - hello", from: "hello", to: "big")]))
    }

    func test_tagDifference() {
        let before = OpenAPI.Tag(
            name: "tag 1",
            description: "first tag"
        )
        let after = OpenAPI.Tag(
            name: "tag 1 (new)",
            description: "first tag for now"
        )

        let comparison = before.compare(to: after, in: "tags")

        XCTAssertEqual(
            comparison,
            .changed(
                "tags",
                diff: [
                    .same("external docs"),
                    .changed(context: "name", from: "tag 1", to: "tag 1 (new)"),
                    .changed(context: "description", from: "first tag", to: "first tag for now")
                ]
            )
        )
    }
}
