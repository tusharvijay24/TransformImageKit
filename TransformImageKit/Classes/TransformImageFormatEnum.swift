//
//  TransformImageFormatEnum.swift
//  TransformImageKit
//
//  Created by Tushar on 28/01/25.
//

import Foundation
import SDWebImage

public enum TransformImageFormatEnum: String, CaseIterable {
    case png = "PNG"
    case jpeg = "JPEG"
    case tiff = "TIFF"
    case gif = "GIF"
    case pdf = "PDF"

    public var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpeg: return "jpeg"
        case .tiff: return "tiff"
        case .gif: return "gif"
        case .pdf: return "pdf"
        }
    }

    public var sdFormat: SDImageFormat? {
        switch self {
        case .png: return .PNG
        case .jpeg: return .JPEG
        case .tiff: return .TIFF
        case .gif: return .GIF
        default: return nil
        }
    }
}
