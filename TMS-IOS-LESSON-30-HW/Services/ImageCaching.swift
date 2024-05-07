import UIKit


protocol ImageCachingProtocol {
    static var queue: DispatchQueue { get set }
    static func saveImage(_ image: UIImage?,_ imageName: String,   completion: @escaping (_ name: String) -> ())
    static func loadImage(name: String, completion: @escaping (_ img: UIImage?) -> ())
    static func removeImage(name: String, completion: @escaping () -> ())
}

class ImageCaching: ImageCachingProtocol {
    
    static internal var queue: DispatchQueue = DispatchQueue(label: "image-caching")
    
    static var imagesDirectory: URL {
        get {
            let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            
            return URL(fileURLWithPath: "images", relativeTo: directoryURL)
        }
    }
    
    static func saveImage(_ image: UIImage?,_ imageName: String, completion: @escaping (_ name: String) -> ()) {
        let name = URL(fileURLWithPath: imageName, relativeTo: self.imagesDirectory).appendingPathExtension("png")
        
        guard let data = image?.pngData() else {
            return
        }
        
        queue.async(flags: .barrier) {
            do {
                try data.write(to: name)
                let prevData = StorageService.getValue(key: Keys.images) as? [String]
                guard var prevData = prevData else {
                    StorageService.setValue(key: Keys.images, value: ["\(name.lastPathComponent)"])
                    completion(name.lastPathComponent)
                    return
                }
                prevData.append(name.lastPathComponent)
                StorageService.setValue(key: Keys.images, value: prevData)
                completion(name.lastPathComponent)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func loadImage(name: String, completion: @escaping (_ img: UIImage?) -> ()) {
        queue.async(flags: .barrier) {
            do {
                let cachedImageDirectory = URL(fileURLWithPath: name, relativeTo: self.imagesDirectory)
                let imageName = URL(fileURLWithPath: name, relativeTo: cachedImageDirectory)
                
                let savedData = try Data(contentsOf: imageName)
                
                if let cachedImage = UIImage(data: savedData) {
                    completion(cachedImage)
                }
                else {
                    completion(nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    static func removeImage(name: String, completion: @escaping () -> ()) {
        queue.async(flags: .barrier) {
            do {
                let cachedImageDirectory = URL(fileURLWithPath: name, relativeTo: self.imagesDirectory)
                
                let imageName = URL(fileURLWithPath: name, relativeTo: cachedImageDirectory)
                let prevData = StorageService.getValue(key: Keys.images) as? [String]
                
                guard var prevData = prevData else {
                    StorageService.setValue(key: Keys.images, value: ["\(imageName.lastPathComponent)"])
                    return
                }
                prevData.removeAll { $0 == imageName.lastPathComponent }
                StorageService.setValue(key: Keys.images, value: prevData)
                
                try? FileManager.default.removeItem(at: imageName)
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

