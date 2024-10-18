import Foundation

enum Configuration {
    enum Error: Swift.Error, LocalizedError {
        case missingKey(String)
        case invalidValue(String)
        
        var errorDescription: String? {
            switch self {
            case .missingKey(let key):
                return "Missing configuration key: \(key)"
            case .invalidValue(let key):
                return "Invalid value for configuration key: \(key)"
            }
        }
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey(key)
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue(key)
        }
    }
}
