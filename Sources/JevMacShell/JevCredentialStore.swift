import Foundation
import Security

enum JevCredentialStoreError: Error, LocalizedError, Sendable {
    case invalidKey
    case keychainFailure(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "The TypeSafe API key was empty or contained unsupported whitespace."
        case let .keychainFailure(status):
            return "The macOS Keychain rejected the credential operation (status \(status))."
        }
    }
}

final class JevCredentialStore: @unchecked Sendable {
    static let shared = JevCredentialStore()

    private static let service = "ai.doomade.jev.prototype.typesafe-api-key"
    private static let account = "typesafe-api-key"

    private init() {}

    func hasCredential() -> Bool {
        (try? load()) != nil
    }

    func load() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw JevCredentialStoreError.keychainFailure(status)
        }
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty else {
            throw JevCredentialStoreError.invalidKey
        }
        return value
    }

    func save(apiKey: String) throws {
        let value = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty,
              value.count <= 512,
              !value.contains(where: { $0.isWhitespace || $0.isNewline }) else {
            throw JevCredentialStoreError.invalidKey
        }

        let deleteStatus = SecItemDelete(baseQuery as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else {
            throw JevCredentialStoreError.keychainFailure(deleteStatus)
        }

        var item = baseQuery
        item[kSecValueData as String] = Data(value.utf8)

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw JevCredentialStoreError.keychainFailure(status)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw JevCredentialStoreError.keychainFailure(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.service,
            kSecAttrAccount as String: Self.account
        ]
    }
}

enum LiveJevConfiguration {
    private static let enabledDefaultsKey = "jev.liveSelection.enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledDefaultsKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledDefaultsKey)
    }
}
