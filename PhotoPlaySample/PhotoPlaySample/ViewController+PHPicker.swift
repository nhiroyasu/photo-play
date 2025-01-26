import UIKit
import PhotosUI

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        Task {
            let images = await loads(for: results)
            if let image = images.first,
               let cgImage = cgImageWithCorrectOrientation(image: image) {
                picker.dismiss(animated: true) { [weak self] in
                    self?.presentPhotoPlay(image: cgImage)
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
    }

    func loads(for pickerResults: [PHPickerResult]) async -> [UIImage] {
        await withTaskGroup(of: UIImage?.self) { group in
            for result in pickerResults {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                                if let _ = error {
                                    continuation.resume(returning: nil)
                                    return
                                }
                                if let image = image as? UIImage {
                                    continuation.resume(returning: image)
                                    return
                                }
                                continuation.resume(returning: nil)
                            }
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }

            var images = [UIImage]()
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
}
