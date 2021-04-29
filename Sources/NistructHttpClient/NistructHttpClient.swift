import Foundation

struct NistructHttpClient {
    private let url: String
    private let anSession: URLSession
    private let anAuthenticator: Authenticatable
    private let aTokenProvider: TokenProvidable
    
    init(baseUrl: String,
         session: URLSession = SessionHandler.defaultSession,
         authenticator: Authenticatable,
         tokenProvider: TokenProvidable) {
        self.url = baseUrl
        self.anSession = session
        self.anAuthenticator = authenticator
        self.aTokenProvider = tokenProvider
    }
    
    static func setup(baseUrl: String,
                      session: URLSession = SessionHandler.defaultSession,
                      authenticator: Authenticatable,
                      tokenProvider: TokenProvidable) -> NistructHttpClient {
        NistructHttpClient(baseUrl: baseUrl,
                           session: session,
                           authenticator: authenticator,
                           tokenProvider: tokenProvider)
    }
}

extension NistructHttpClient: HttpClient {
    var session: URLSession { anSession }
    var baseURL: String { url }
    var authenticator: Authenticatable { anAuthenticator }
    var tokenProvider: TokenProvidable { aTokenProvider }
}
