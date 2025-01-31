# TransformImageKit

[![CI Status](https://img.shields.io/travis/tusharvijay24/TransformImageKit.svg?style=flat)](https://travis-ci.org/tusharvijay24/TransformImageKit)  [![Version](https://img.shields.io/cocoapods/v/TransformImageKit.svg?style=flat)](https://cocoapods.org/pods/TransformImageKit)  [![License](https://img.shields.io/cocoapods/l/TransformImageKit.svg?style=flat)](https://cocoapods.org/pods/TransformImageKit)  [![Platform](https://img.shields.io/cocoapods/p/TransformImageKit.svg?style=flat)](https://cocoapods.org/pods/TransformImageKit)

**TransformImageKit** is a powerful Swift library designed for image conversion, resizing, and compression in iOS applications.

---

## 📌 Features
✅ Convert images to different formats (PNG, JPEG, etc.)  
✅ Resize images while maintaining aspect ratio  
✅ Compress images with customizable quality settings  
✅ Batch process multiple images and zip the output  
✅ Simple and easy-to-use API  

---

## 📥 Installation
### Using CocoaPods
To install **TransformImageKit**, add the following line to your `Podfile`:

```ruby
pod 'TransformImageKit', :git => 'https://github.com/tusharvijay24/TransformImageKit.git'
```

Then, run:
```sh
pod install
```

---

## 🚀 How to Use
### Import TransformImageKit
```swift
import TransformImageKit
```

### Convert Image Format
```swift
let imageManager = TransformImageManager()
let imageURL = URL(string: "path/to/image.jpg")
imageManager.convertImage(at: imageURL, format: .png) { result in
    switch result {
    case .success(let convertedURL):
        print("Converted Image URL: \(convertedURL)")
    case .failure(let error):
        print("Conversion failed: \(error.localizedDescription)")
    }
}
```

### Resize an Image
```swift
imageManager.resizeImage(at: imageURL, width: 500, height: 500) { result in
    switch result {
    case .success(let resizedURL):
        print("Resized Image URL: \(resizedURL)")
    case .failure(let error):
        print("Resizing failed: \(error.localizedDescription)")
    }
}
```

### Compress an Image
```swift
imageManager.compressImage(at: imageURL, quality: 0.7) { result in
    switch result {
    case .success(let compressedURL):
        print("Compressed Image URL: \(compressedURL)")
    case .failure(let error):
        print("Compression failed: \(error.localizedDescription)")
    }
}
```

### Batch Convert and Zip Images
```swift
let images = [URL(string: "path/to/image1.jpg"), URL(string: "path/to/image2.jpg")]
imageManager.convertAndZipImages(imagePaths: images, format: .png, pixelWidth: 1024, pixelHeight: 768, compressionQuality: 0.8) { result in
    switch result {
    case .success(let zipURL):
        print("Zipped Images URL: \(zipURL)")
    case .failure(let error):
        print("Batch conversion failed: \(error.localizedDescription)")
    }
}
```

---

## 📦 Example Project
To see TransformImageKit in action, clone the repository and run the example project:

```bash
git clone https://github.com/tusharvijay24/TransformImageKit.git
cd TransformImageKit/Example
pod install
open TransformImageKit.xcworkspace
```

---

## 📄 License
TransformImageKit is available under the **MIT License**. See the `LICENSE` file for more details.

---

## 👤 Author
Tushar Vijayvargiya  
[tusharvijayvargiya24112000@gmail.com](mailto:tusharvijayvargiya24112000@gmail.com)

