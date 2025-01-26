import UIKit
import CoreImage
import PhotosUI

extension ViewController {
    func authorizePhotoLibrary(authorizedHandler: @escaping () -> Void) {
        let currentPHStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch currentPHStatus {
        case .authorized, .limited:
            authorizedHandler()
        case .notDetermined, .denied:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async { authorizedHandler() }
                default:
                    print("Other status: \(status)", #file, #function, #line)
                }
            }
        default:
            print("Other status: \(currentPHStatus)", #file, #function, #line)
        }
    }
}
