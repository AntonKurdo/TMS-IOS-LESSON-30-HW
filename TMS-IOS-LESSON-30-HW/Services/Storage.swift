import Foundation

enum Keys {
    static let images = "images"
}

protocol StorageServiceProtocol {
    static var storage: UserDefaults {get set}
    static var queue: DispatchQueue { get set }
    static func getValue(key: String) -> Any?
    static func setValue(key: String, value: Any)
}

class StorageService: StorageServiceProtocol {
    static internal var storage: UserDefaults = UserDefaults.standard
    static internal var queue: DispatchQueue = DispatchQueue(label: "user-defaults-queue")
    
    static func getValue(key: String) -> Any? {
        var value: (Any)? = nil
        queue.sync {
            value = storage.array(forKey: key)
        }
        return value ?? nil
    }
    
    static func setValue(key: String, value: Any) {
        queue.sync {
            storage.setValue(value, forKey: key)
        }
    }
}
