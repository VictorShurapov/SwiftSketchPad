//
//  CanvasViewModel.swift
//  SwiftSketchPad
//
//  Created by Yaro4ka on 08.04.2025.
//

import Foundation

// ViewModel to store lines and grid properties
@Observable
final class CanvasViewModel {
    struct Line: Identifiable {
        let id = UUID()
        var start: CGPoint
        var end: CGPoint

        var length: CGFloat {
            hypot(end.x - start.x, end.y - start.y)
        }
        
        // Define clearly: 10 points = 1 cm
        let pointsPerCm: CGFloat = 10
        var lengthInCm: CGFloat {
            length / pointsPerCm
        }
    }

    var lines: [Line] = []
    var currentLine: Line?
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var isPanning: Bool = false
}

