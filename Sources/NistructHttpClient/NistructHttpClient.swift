import Foundation

public struct NistructHttpClient {
    private let auth: String
    private let api: String
    private let anSession: URLSession
    private let anAuthenticator: Authenticatable
    private let aTokenProvider: TokenProvidable
    
    public init(authUrl: String,
                apiUrl: String,
                session: URLSession = SessionHandler.defaultSession,
                authenticator: Authenticatable,
                tokenProvider: TokenProvidable) {
        self.auth = authUrl
        self.api = apiUrl
        self.anSession = session
        self.anAuthenticator = authenticator
        self.aTokenProvider = tokenProvider
    }
    
    public static func setup(authUrl: String,
                             apiUrl: String,
                             session: URLSession = SessionHandler.defaultSession,
                             authenticator: Authenticatable,
                             tokenProvider: TokenProvidable) -> NistructHttpClient {
        NistructHttpClient(authUrl: authUrl,
                           apiUrl: apiUrl,
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
    public var authURL: String { auth }
    public var apiURL: String { api }
    public var authenticator: Authenticatable { anAuthenticator }
    public var tokenProvider: TokenProvidable { aTokenProvider }
}
