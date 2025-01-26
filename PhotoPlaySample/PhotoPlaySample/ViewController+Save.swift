import UIKit

extension ViewController {
    func showSaveAlert(imageData: Data) {
        let alert = UIAlertController(
            title: "Save Image",
            message: "Input the name of the image",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Image Name"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            textField.text = "Unnamed_\(dateFormatter.string(from: Date()))"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            defer { alert.dismiss(animated: true) }

            guard let text = alert.textFields?.first?.text else { return }

            if let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let fileUrl = documentsDirectory.appendingPathComponent(text + ".jpeg")
                do {
                    try imageData.write(to: fileUrl)
                    print("Saved image to", fileUrl)

                    if let url = URL(string: "shareddocuments://") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("ファイルアプリが開けません")
                        }
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        })
        present(alert, animated: true)
    }
}
