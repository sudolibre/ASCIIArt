//: Playground - noun: a place where people can play

import UIKit
import Foundation
import AVFoundation
import ImageIO



class AsciiArtist {
    private let
    image:   UIImage,
    palette: AsciiPalette
    
    init(_ image: UIImage, _ palette: AsciiPalette)
    {
        self.image   = image
        self.palette = palette
    }
    
    func createAsciiArt() -> String
    {
        let
        dataProvider = image.cgImage!.dataProvider,
        pixelData    = dataProvider!.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        intensities  = intensityMatrixFromPixelPointer(pointer: pixelPointer!),
        symbolMatrix = symbolMatrixFromIntensityMatrix(matrix: intensities)
        return symbolMatrix.joined(separator: "\n")
    }
    
    private func intensityMatrixFromPixelPointer(pointer: PixelPointer) -> [[Double]]
    {
        let
        width  = Int(image.size.width),
        height = Int(image.size.height),
        matrix = Pixel.createPixelMatrix(width: width, height)
        return matrix.map { pixelRow in
            pixelRow.map { pixel in
                pixel.intensityFromPixelPointer(pointer: pointer)
            }
        }
    }
    
    private func symbolMatrixFromIntensityMatrix(matrix: [[Double]]) -> [String]
    {
        return matrix.map { intensityRow in
            intensityRow.reduce("") {
                $0 + self.symbolFromIntensity(intensity: $1)
            }
        }
    }
    
    private func symbolFromIntensity(intensity: Double) -> String
    {
        assert(0.0 <= intensity && intensity <= 1.0)
        
        let
        factor = palette.symbols.count - 1,
        value  = round(intensity * Double(factor)),
        index  = Int(value)
        return palette.symbols[index]
    }
}

class AsciiPalette
{
    private let font: UIFont
    
    init(font: UIFont) { self.font = font }
    
    lazy var symbols: [String] = self.loadSymbols()
    
    private func loadSymbols() -> [String]
    {
        return symbolsSortedByIntensityForAsciiCodes(codes: 32..<127) // from ' ' to '~'
    }
    
    private func symbolsSortedByIntensityForAsciiCodes(codes: CountableRange<Int>) -> [String]
    {
        let
        symbols          = codes.map { self.symbolFromAsciiCode(code: $0) },
        symbolImages     = symbols.map { UIImage.imageOfSymbol(symbol: $0, self.font) },
        whitePixelCounts = symbolImages.map { self.countWhitePixelsInImage(image: $0) },
        sortedSymbols    = sortByIntensity(symbols: symbols, whitePixelCounts)
        return sortedSymbols
    }
    
    private func symbolFromAsciiCode(code: Int) -> String
    {
        return String(Character(UnicodeScalar(code)!))
    }
    
    private func countWhitePixelsInImage(image: UIImage) -> Int
    {
        let
        dataProvider = image.cgImage!.dataProvider,
        pixelData    = dataProvider!.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        byteCount    = CFDataGetLength(pixelData),
        pixelOffsets = stride(from: 0, to: byteCount, by: Pixel.bytesPerPixel)
        //pixelOffsets = 0.stride(to: byteCount, by: Pixel.bytesPerPixel)
        return pixelOffsets.reduce(0) { (count, offset) -> Int in
            let
            r = pixelPointer?[offset + 0],
            g = pixelPointer?[offset + 1],
            b = pixelPointer?[offset + 2],
            isWhite = (r == 255) && (g == 255) && (b == 255)
            return isWhite ? count + 1 : count
        }
    }
    
    private func sortByIntensity(symbols: [String], _ whitePixelCounts: [Int]) -> [String]
    {
        let
        mappings      = NSDictionary(objects: symbols, forKeys: whitePixelCounts as [NSCopying]),
        uniqueCounts  = Set(whitePixelCounts),
        sortedCounts  = uniqueCounts.sorted(),
        sortedSymbols = sortedCounts.map { mappings[$0] as! String }
        return sortedSymbols
    }
}

typealias PixelPointer = UnsafePointer<UInt8>

/** A point in an image converted to an ASCII character. */
struct Pixel
{
    /** The number of bytes a pixel occupies. 1 byte per channel (RGBA). */
    static let bytesPerPixel = 4
    
    private let offset: Int
    private init(_ offset: Int) { self.offset = offset }
    
    static func createPixelMatrix(width: Int, _ height: Int) -> [[Pixel]]
    {
        return (0..<height).map { row in
            (0..<width).map { col in
                let offset = (width * row + col) * Pixel.bytesPerPixel
                return Pixel(offset)
            }
        }
    }
    
    func intensityFromPixelPointer(pointer: PixelPointer) -> Double
    {
        let
        red   = pointer[offset + 0],
        green = pointer[offset + 1],
        blue  = pointer[offset + 2]
        return Pixel.calculateIntensity(r: red, green, blue)
        //return Pixel.calculateIntensity(red, blue, green)
    }
    
    private static func calculateIntensity(r: UInt8, _ g: UInt8, _ b: UInt8) -> Double
    {
        // Normalize the pixel's grayscale value to between 0 and 1.
        // Weights from http://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
        let
        redWeight   = 0.229,
        greenWeight = 0.587,
        blueWeight  = 0.114,
        weightedMax = 255.0 * redWeight   +
            255.0 * greenWeight +
            255.0 * blueWeight,
        weightedSum = Double(r) * redWeight   +
            Double(g) * greenWeight +
            Double(b) * blueWeight
        return weightedSum / weightedMax
    }
}

 extension UIImage
{
    class func imageOfSymbol(symbol: String, _ font: UIFont) -> UIImage
    {
        let
        length = font.pointSize * 2,
        size   = CGSize(width: length, height: length),
        rect   = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Fill the background with white.
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(rect)
        
        // Draw the character with black.
        let nsString = NSString(string: symbol)
        nsString.draw(at: rect.origin, withAttributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.black
            ])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func imageConstrainedToMaxSize(maxSize: CGSize) -> UIImage
    {
        let isTooBig =
            size.width  > maxSize.width ||
                size.height > maxSize.height
        if isTooBig
        {
            let
            maxRect       = CGRect(origin: CGPoint(x: 0, y: 0), size: maxSize),
            scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPoint(x: 0, y: 0), size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.cgImage,
            bitsPerComp   = cgImage!.bitsPerComponent,
            compsPerPixel = 4, // RGBA
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = cgImage!.colorSpace,
            bitmapInfo    = cgImage!.bitmapInfo,
            context       = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComp,
                bytesPerRow: bytesPerRow,
                space: colorSpace!,
                bitmapInfo: bitmapInfo.rawValue)
            
            if context != nil
            {
                context!.interpolationQuality = CGInterpolationQuality.low
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context!.makeImage()
                {
                    return UIImage(cgImage: scaledCGImage)
                    
                }
            }
        }
        return self
    }
    
}


let labelFont = UIFont(name: "Menlo", size: 7)!
let maxImageSize = CGSize(width: 100, height: 56)
var palette: AsciiPalette = AsciiPalette(font: labelFont)
var currentLabel: UILabel?

palette = AsciiPalette(font: labelFont)

let image = UIImage(named: "tmp-0.gif")
let asciiArtist = AsciiArtist(image!, palette)
let asciiArt = asciiArtist.createAsciiArt()

var url = "http://media2.giphy.com/media/26BRBpyDTwMoJRRFm/100w.gif"
let bundleURL = URL(string: url)
let imageData = try? Data(contentsOf: bundleURL!)
let source = CGImageSourceCreateWithData(imageData as! CFData, nil)

let count = CGImageSourceGetCount(source!)
var images = [CGImage]()
var delays = [Int]()

// Fill arrays
for i in 0..<count {
    // Add image
    if let image = CGImageSourceCreateImageAtIndex(source!, i, nil) {
        images.append(image)
}
}
var frames = [UIImage]()

var frame: UIImage
var frameCount: Int
for i in 0..<count {
    frame = UIImage(cgImage: images[Int(i)])
    frameCount = count
    frames.append(frame)
}

for i in 0..<frames.count {
    let image = frames[i]
    let resizedImage = image.imageConstrainedToMaxSize(maxSize: maxImageSize)
    let asciiArtist = AsciiArtist(resizedImage, palette)
    let asciiArt = asciiArtist.createAsciiArt()
    print(asciiArt)
    sleep(1)
    print("\u{001B}[2J")
    
}

