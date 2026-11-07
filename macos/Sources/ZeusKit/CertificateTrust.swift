import Foundation
import CryptoKit
import Security

/// What the user is shown when asked whether to trust a server's certificate.
public struct CertificateInfo: Sendable, Equatable, Identifiable {
    public var id: String { sha256 }
    /// Lowercase hex SHA-256 of the DER-encoded leaf certificate.
    public let sha256: String
    public let subject: String

    public init(sha256: String, subject: String) { self.sha256 = sha256; self.subject = subject }

    /// "AB:CD:..." for display.
    public var displayFingerprint: String {
        stride(from: 0, to: sha256.count, by: 2).map { i -> String in
            let a = sha256.index(sha256.startIndex, offsetBy: i)
            return sha256[a..<sha256.index(a, offsetBy: 2)].uppercased()
        }.joined(separator: ":")
    }
}

public enum CertificatePin {
    public static func fingerprint(of der: Data) -> String {
        SHA256.hash(data: der).map { String(format: "%02x", $0) }.joined()
    }

    /// Case, colon and whitespace insensitive comparison, so a pasted "AB:CD" fingerprint matches.
    public static func normalize(_ f: String) -> String {
        f.lowercased().filter { $0.isHexDigit }
    }

    /// Whether the presented leaf matches the pin. Empty or missing pins never match.
    public static func matches(pin: String?, leafDER: Data) -> Bool {
        guard let pin, !normalize(pin).isEmpty else { return false }
        return normalize(pin) == fingerprint(of: leafDER)
    }
}

/// URLSession delegate: system validation decides first. Only when it fails is the leaf compared with the
/// pinned fingerprint; a mismatch cancels the request and remembers the certificate so the UI can offer it.
public final class CertificateTrust: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let pin: String?
    private let lock = NSLock()
    private var rejected: CertificateInfo?

    public init(pinnedFingerprint: String?) { pin = pinnedFingerprint }

    public func takeRejected() -> CertificateInfo? {
        lock.lock(); defer { lock.unlock() }
        defer { rejected = nil }
        return rejected
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil); return
        }
        var err: CFError?
        if SecTrustEvaluateWithError(trust, &err) {
            completionHandler(.performDefaultHandling, nil); return
        }
        guard let leaf = (SecTrustCopyCertificateChain(trust) as? [SecCertificate])?.first else {
            completionHandler(.cancelAuthenticationChallenge, nil); return
        }
        let der = SecCertificateCopyData(leaf) as Data
        if CertificatePin.matches(pin: pin, leafDER: der) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            let info = CertificateInfo(sha256: CertificatePin.fingerprint(of: der),
                                       subject: SecCertificateCopySubjectSummary(leaf) as String? ?? "Unknown")
            lock.lock(); rejected = info; lock.unlock()
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
