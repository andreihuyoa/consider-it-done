//
//  CustomImageProcessor.swift
//  consider it done
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Prepares a user-chosen image for storage on a `SavedItem`: downscaled to a
/// 1600 px long edge and re-encoded as JPEG so the store stays small.
enum CustomImageProcessor {
    nonisolated static let maxPixelSize = 1600
    nonisolated static let jpegQuality = 0.8

    nonisolated static func prepared(_ data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}
