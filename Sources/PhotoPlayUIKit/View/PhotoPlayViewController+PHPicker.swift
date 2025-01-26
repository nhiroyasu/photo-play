import UIKit
import PhotosUI

extension PhotoPlayViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        Task {
            let images = await loads(for: results)
            if let image = images.first,
               let cgImage = cgImageWithCorrectOrientation(image: image) {
                picker.dismiss(animated: true) { [weak self] in
                    self?.selectedImage(image: cgImage)
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
    }

    private func loads(for pickerResults: [PHPickerResult]) async -> [UIImage] {
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

    private func cgImageWithCorrectOrientation(image: UIImage) -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }.cgImage
    }
}
