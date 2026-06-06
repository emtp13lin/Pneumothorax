
import Foundation
import Vision
import AppKit

func performOCR(imagePath: String) {
    let imageURL = URL(fileURLWithPath: imagePath)
    guard let image = NSImage(contentsOf: imageURL) else {
        print("Failed to load image: \(imagePath)")
        return
    }
    
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to get CGImage")
        return
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let request = VNRecognizeTextRequest { (request, error) in
        if let error = error {
            print("Error in OCR: \(error)")
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            print("No observations found")
            return
        }
        
        var recognizedText = ""
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            recognizedText += candidate.string + "\n"
        }
        print(recognizedText)
    }
    
    // Set text recognition configuration
    request.recognitionLevel = .accurate
    // Enable language correction and support Chinese/English
    request.recognitionLanguages = ["zh-Hant", "en-US"]
    
    do {
        try requestHandler.perform([request])
    } catch {
        print("Failed to perform OCR: \(error)")
    }
}

let args = CommandLine.arguments
if args.count < 2 {
    print("Usage: swift_ocr <path_to_image>")
    exit(1)
}
performOCR(imagePath: args[1])
