//
//  SessionHandler.swift
//
//  Created by Nikola Nikolic on 11/30/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public class SessionHandler: NSObject {
    public static let defaultSession: URLSession = {
        return SessionHandler(sslPinning: false).session
    }()
    
    public static let sslPinningSession: URLSession = {
        return SessionHandler(sslPinning: true).session
    }()
    
    private var session: URLSession!
    
    private static var certificateNameList: [String] {
        get {
            guard let secret = Bundle.main.infoDictionary?[Keys.CertName] as? String else {
                return []
            }
            return secret.components(separatedBy: ",")
        }
    }
    
    public init(sslPinning: Bool) {
        super.init()
        
        let sessionConfiguration = SessionHandler.sessionConfiguration()
        
        var session: URLSession!
        if sslPinning {
            session = URLSession(configuration: sessionConfiguration,
                                 delegate: self,
                                 delegateQueue: nil)
        } else {
            session = URLSession(configuration: sessionConfiguration)
        }
        
        self.session = session
    }
    
    private static func sessionConfiguration() -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
//        sessionConfiguration.timeoutIntervalForResource = 120
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.httpMaximumConnectionsPerHost = 5
        sessionConfiguration.requestCachePolicy = .reloadIgnoringCacheData
        return sessionConfiguration
    }
}

extension SessionHandler: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)
        
        // Set SSL policies for domain name check
        let policies = NSMutableArray()
        let ssl = SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString))
        policies.add(ssl)
        SecTrustSetPolicies(serverTrust!, policies)
        
        // Evaluate server certificate
        var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(serverTrust!, &result)
        let isServerTrusted: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
        
        // Get local and remote cert data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate!)
        
        let certificateNameList = SessionHandler.certificateNameList
        guard certificateNameList.count > 0 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            NotificationCenter.default.post(name: .MissingCertificate, object: nil)
            return
        }
        
        for certificateName in certificateNameList {
            guard let pathToCert = Bundle.main.path(forResource: certificateName, ofType: Keys.CertTypeCer),
                  let localCertificate = NSData(contentsOfFile: pathToCert) else { continue }
            
            log.debug("SSL Certificate: \(String(describing: pathToCert))")
            if isServerTrusted && remoteCertificateData.isEqual(to: localCertificate as Data) {
                let credential: URLCredential = URLCredential(trust: serverTrust!)
                log.debug("SSL Pinning OK")
                completionHandler(.useCredential, credential)
                return
            }
            
            log.error("SSL Pinning Not OK")
        }
        
        NotificationCenter.default.post(name: .InvalidCertificate, object: nil)
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

extension SessionHandler {
    struct Keys {
        static let CertName     = "CERT_NAME"
        static let CertTypeCer  = "cer"
    }
}
