import Foundation

public enum ZeusError: Error, Sendable {
    case unauthorized
    case server(status: Int, message: String)
    case transport(Error)
}

/// Thin async client for the Zeus OS REST API (`/api/v1`).
public final class ZeusClient: Sendable {
    public let baseURL: URL
    private let token: String?
    private let session: URLSession

    public init(baseURL: URL, token: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    public func withToken(_ token: String) -> ZeusClient {
        ZeusClient(baseURL: baseURL, token: token, session: session)
    }

    public func login(username: String, password: String) async throws -> LoginResponse {
        try await send("auth/login", method: "POST",
                       body: ["username": username, "password": password])
    }

    public func vms() async throws -> [VM] {
        let page: Page<VM> = try await send("vms")
        return page.items
    }

    /// Power actions. The endpoints take an optional free-form body and return free-form JSON,
    /// which we ignore: callers re-read `vms()` to see the resulting state.
    public func perform(_ action: VMAction, on vm: VM) async throws {
        _ = try await raw(try request(Self.actionPath(action, vm), method: "POST"))
    }

    static func actionPath(_ action: VMAction, _ vm: VM) -> String {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let ns = vm.namespace.addingPercentEncoding(withAllowedCharacters: allowed) ?? vm.namespace
        let name = vm.name.addingPercentEncoding(withAllowedCharacters: allowed) ?? vm.name
        return "vms/\(ns)/\(name)/\(action.rawValue)"
    }

    public func alertStats() async throws -> AlertStats {
        try await send("alerts/stats")
    }

    func request(_ path: String, method: String = "GET", body: [String: String]? = nil) throws -> URLRequest {
        var req = URLRequest(url: baseURL.appending(path: "api/v1/\(path)"))
        req.httpMethod = method
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    func raw(_ req: URLRequest) async throws -> Data {
        let data: Data, resp: URLResponse
        do { (data, resp) = try await session.data(for: req) }
        catch { throw ZeusError.transport(error) }
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0
        if status == 401 { throw ZeusError.unauthorized }
        guard (200..<300).contains(status) else {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? ""
            throw ZeusError.server(status: status, message: msg)
        }
        return data
    }

    func send<T: Decodable>(_ path: String, method: String = "GET",
                            body: [String: String]? = nil) async throws -> T {
        let data = try await raw(try request(path, method: method, body: body))
        return try JSONDecoder().decode(T.self, from: data)
    }
}
