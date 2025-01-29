# Photo Play
A Pure Swift Image Editting Library.

# Usage
```swift
import PhotoPlayUIKit

func presentPhotoPlay(image: CGImage) {
    let vc = PhotoPlayViewController(image: image) { editedImage in
        // You can use a edited image
    }
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
}
```

# Sample
You can try the sample project by cloning the repository and opening `PhotoPlaySample/PhotoPlaySample.xcodeproj`.

# Feature
## Image Control
<img src="https://github.com/user-attachments/assets/28ef74f0-98b9-4540-bd2f-363764f66d92" width=300 />

## Filter
<img src="https://github.com/user-attachments/assets/4a00698f-0c75-4858-8973-011a9c66ce79" width=300 />

## Paint
<img src="https://github.com/user-attachments/assets/c5b73673-bdaa-4741-8687-b10e59a8a6ef" width=300 />

## Overlay Image and Text
<img src="https://github.com/user-attachments/assets/6fa510aa-a760-45fd-bda0-4cdc28911f35" width=300 />

# Preview
![Simulator Screen Recording - iPhone 16 Pro - 2025-01-30 at 00 06 59_3](https://github.com/user-attachments/assets/d49ce939-47be-4fbb-a9b3-aee88b47b77e)
