//
//  TransformImageManager.swift
//  TransformImageKit
//
//  Created by Tushar on 28/01/25.
//

import UIKit
import ZIPFoundation
import SDWebImage
import CoreImage

public class TransformImageManager {
    
    public init() {}
    
    public let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    /// Converts and zips images into the specified format.
    public func convertAndZipImages(
        imagePaths: [URL],
        format: TransformImageFormatEnum,
        pixelWidth: Int?,
        pixelHeight: Int?,
        compressionQuality: Double?,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let imagesDirectory = self.prepareDirectory(named: "images")
            
            do {
                for (index, imagePath) in imagePaths.enumerated() {
                    let fileName = "image_\(index + 1).\(format.fileExtension)"
                    let fileURL = imagesDirectory.appendingPathComponent(fileName)
                    
                    guard let image = UIImage(contentsOfFile: imagePath.path) else {
                        throw self.createError(message: "Unable to load image at path: \(imagePath.path)")
                    }
                    
                    try self.convertImage(image, format: format, to: fileURL, pixelWidth: pixelWidth, pixelHeight: pixelHeight, compressionQuality: compressionQuality)
                }
                
                let zipURL = self.documentsDirectory.appendingPathComponent("converted_images.zip")
                if FileManager.default.fileExists(atPath: zipURL.path) {
                    try FileManager.default.removeItem(at: zipURL)
                }
                try FileManager.default.zipItem(at: imagesDirectory, to: zipURL, shouldKeepParent: false)
                
                DispatchQueue.main.async {
                    completion(.success(zipURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Prepares a directory by clearing existing contents and creating a fresh directory.
    public func prepareDirectory(named name: String) -> URL {
        let directory = documentsDirectory.appendingPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.removeItem(at: directory)
            }
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error preparing directory: \(error.localizedDescription)")
        }
        return directory
    }
    
    /// Converts an image into the specified format and saves it to the given URL.
    public func convertImage(
        _ image: UIImage,
        format: TransformImageFormatEnum,
        to url: URL,
        pixelWidth: Int?,
        pixelHeight: Int?,
        compressionQuality: Double?
    ) throws {
        let resizedImage = resizeImage(image, to: pixelWidth, and: pixelHeight)
        
        switch format {
        case .png, .jpeg, .tiff, .gif:
            try saveStandardImage(resizedImage, as: format, to: url, compressionQuality: compressionQuality)
        case .pdf:
            try savePDFImage(resizedImage, to: url)
        }
    }
    
    /// Saves standard image formats supported by SDWebImage.
    public func saveStandardImage(
        _ image: UIImage,
        as format: TransformImageFormatEnum,
        to url: URL,
        compressionQuality: Double?
    ) throws {
        guard let sdFormat = format.sdFormat else {
            throw createError(message: "Unsupported standard format: \(format.rawValue)")
        }
        let compression = compressionQuality ?? 1.0
        guard let data = image.sd_imageData(as: sdFormat, compressionQuality: compression) else {
            throw createError(message: "Failed to convert image to \(format.rawValue)")
        }
        try data.write(to: url)
    }
    
    /// Saves an image in PDF format.
    public func savePDFImage(_ image: UIImage, to url: URL) throws {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        try data.write(to: url)
    }
    
    /// Resizes an image to the given dimensions while maintaining its aspect ratio.
    public func resizeImage(_ image: UIImage, to width: Int?, and height: Int?) -> UIImage {
        guard let width = width, let height = height else { return image }
        let newSize = CGSize(width: width, height: height)
        return image.sd_resizedImage(with: newSize, scaleMode: .aspectFit) ?? image
    }
    
    /// Creates a standardized error with a given message.
    public func createError(message: String) -> NSError {
        return NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
