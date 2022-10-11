import Foundation

public struct NistructHttpClient {
    private let url: String
    private let anSession: URLSession
    private let anAuthenticator: Authenticatable
    private let aTokenProvider: TokenProvidable
    
    public init(baseUrl: String,
                session: URLSession = SessionHandler.defaultSession,
                authenticator: Authenticatable,
                tokenProvider: TokenProvidable) {
        self.url = baseUrl
        self.anSession = session
        self.anAuthenticator = authenticator
        self.aTokenProvider = tokenProvider
    }
    
    public static func setup(baseUrl: String,
                             session: URLSession = SessionHandler.defaultSession,
                             authenticator: Authenticatable,
                             tokenProvider: TokenProvidable) -> NistructHttpClient {
        NistructHttpClient(baseUrl: baseUrl,
                           session: session,
                           authenticator: authenticator,
                           tokenProvider: tokenProvider)
    }
    
    public static func startLogging() {
        Log.start()
    }
}

extension NistructHttpClient: HttpClient {
    public var session: URLSession { anSession }
    public var baseURL: String { url }
    public var authenticator: Authenticatable { anAuthenticator }
    public var tokenProvider: TokenProvidable { aTokenProvider }
}
