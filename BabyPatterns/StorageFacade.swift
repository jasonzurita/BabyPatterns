import Common
import Firebase
import Foundation
import Framework_BabyPatterns
import Library

struct StorageFacade: Loggable {
    let shouldPrintDebugLog = true

    private let storageReference = Storage.storage().reference()
    typealias DownloadResponseHandler = (_ data: Data?, _ error: Error?) -> Void

    func uploadData(data: Data, requestType type: FirebaseRequestType) {
        log("Uploading \(type.rawValue)...", object: self, type: .info)
        guard let fullReference = pathForRequest(type: type) else {
            let message = "Couldn't make full storage reference for path with request type: \(type.rawValue)"
            log(message, object: self, type: .error)
            return
        }
        fullReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil && error == nil else {
                // TODO: handle error?
                self.log("Failure uploading \(type.rawValue)", object: self, type: .error)
                return
            }
            self.log("Upload complete! - \(type.rawValue)", object: self, type: .info)
        }
    }

    func download(requestType type: FirebaseRequestType, callback: @escaping DownloadResponseHandler) {
        guard let fullReference = pathForRequest(type: type) else { return }

        // TODO: wrap data & error in a request object
        fullReference.getData(maxSize: 100 * 1024 * 1024, completion: { data, error in
            callback(data, error)
        })
    }

    private func pathForRequest(type: FirebaseRequestType) -> StorageReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return storageReference.child("/users/" + uid + "/" + type.rawValue)
    }
}
