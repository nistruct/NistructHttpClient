    import XCTest
    @testable import NistructHttpClient

    final class NistructHttpClientTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            let client = NistructHttpClient(authUrl: String.TestAuthUrl,
                                            apiUrl: String.TestApiUrl,
                                            authenticator: FakeAuthenticator(),
                                            tokenProvider: FakeTokenProvider())
            XCTAssertEqual(client.authURL, String.TestAuthUrl)
            XCTAssertEqual(client.apiURL, String.TestApiUrl)
        }
    }
