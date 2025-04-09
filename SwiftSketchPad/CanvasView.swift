//
//  CanvasView.swift
//  SwiftSketchPad
//
//  Created by Yaro4ka on 08.04.2025.
//

import SwiftUI

// Canvas View containing the grid, lines, and interactions
struct CanvasView: View {
    @Environment(CanvasViewModel.self) private var viewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    gridView(size: geo.size)
                    linesView
                    currentLineView
                }
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .animation(.easeInOut, value: viewModel.scale)

                panToggleView
            }
            .padding(.top, 20)

        }
        .edgesIgnoringSafeArea(.all)
    }

    // Grid View with fixed logical units
    private func gridView(size: CGSize) -> some View {
        Canvas { context, _ in
            let baseGridSize: CGFloat = 50
            let scale = viewModel.scale
            let scaledGridSize = baseGridSize * scale

            let offset = viewModel.offset
            let midX = size.width / 2 + offset.width
            let midY = size.height / 2 + offset.height

            var path = Path()

            let horizontalCount = Int(size.width / scaledGridSize) + 2
            let verticalCount = Int(size.height / scaledGridSize) + 2

            for i in -horizontalCount...horizontalCount {
                let x = midX + CGFloat(i) * scaledGridSize
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            for i in -verticalCount...verticalCount {
                let y = midY + CGFloat(i) * scaledGridSize
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(path, with: .color(.gray.opacity(0.4)))
        }
    }

    // Drawing saved lines with dynamic text
    private var linesView: some View {
        ForEach(viewModel.lines) { line in
            Path { path in
                path.move(to: line.start)
                path.addLine(to: line.end)
            }
            .stroke(Color.blue, lineWidth: 2)
            .overlay(
                Text("\(Int(line.lengthInCm)) cm")
                    .font(.system(size: max(12 / viewModel.scale, 8)))
                    .padding(4)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(5)
                    .position(midPoint(line.start, line.end))
            )
        }
    }

    // Current line being drawn
    private var currentLineView: some View {
        Group {
            if let currentLine = viewModel.currentLine {
                Path { path in
                    path.move(to: currentLine.start)
                    path.addLine(to: currentLine.end)
                }
                .stroke(Color.red, lineWidth: 2)
            }
        }
    }

    // Toggle for Pan Mode
    private var panToggleView: some View {
        VStack {
            Toggle("Pan Mode", isOn: Binding(
                get: { viewModel.isPanning },
                set: { viewModel.isPanning = $0 }
            ))
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding()
            Spacer()
            
            HStack(spacing: 10) {
                Button("Reset Zoom & Pan") {
                    viewModel.scale = 1.0
                    viewModel.offset = .zero
                }
                .buttonStyle(.borderedProminent)

                Button("Clear Canvas") {
                    viewModel.lines.removeAll()
                    viewModel.currentLine = nil
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom)
        }
    }
    
    // Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if viewModel.isPanning {
                    viewModel.offset.width += value.translation.width
                    viewModel.offset.height += value.translation.height
                } else {
                    if viewModel.currentLine == nil {
                        viewModel.currentLine = CanvasViewModel.Line(start: value.startLocation, end: value.location)
                    } else {
                        viewModel.currentLine?.end = value.location
                    }
                }
            }
            .onEnded { _ in
                if !viewModel.isPanning, let newLine = viewModel.currentLine {
                    viewModel.lines.append(newLine)
                    viewModel.currentLine = nil
                }
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                viewModel.scale = value.magnitude
            }
            .onEnded { _ in
                viewModel.scale = min(max(viewModel.scale, 0.5), 5.0)
            }
    }

    // Helper for midpoint calculation
    private func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}


#Preview {
    CanvasView()
}
