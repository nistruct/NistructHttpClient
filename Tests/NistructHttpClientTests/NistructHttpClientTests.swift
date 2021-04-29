    import XCTest
    @testable import NistructHttpClient

    final class NistructHttpClientTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            let client = NistructHttpClient(baseUrl: String.TestBaseUrl,
                                            authenticator: FakeAuthenticator(),
                                            tokenProvider: FakeTokenProvider())
            XCTAssertEqual(client.baseURL, String.TestBaseUrl)
        }
    }
