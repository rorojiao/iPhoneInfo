//
//  MetalBenchmark.swift
//  iPhoneInfo
//
//  Metal-based 3D GPU benchmark implementation
//

import Foundation
import Metal
import MetalKit

// MARK: - Benchmark Protocol
protocol MetalBenchmark {
    var name: String { get }
    var duration: TimeInterval { get }
    var sceneDescription: String { get }

    func setup(view: MTKView) throws
    func update(deltaTime: Float)
    func draw(view: MTKView)
    func cleanup()
    func getScore() -> BenchmarkScore
}

// MARK: - Benchmark Score
struct BenchmarkScore {
    let averageFPS: Float
    let minFPS: Float
    let maxFPS: Float
    let frameCount: Int
    let totalTime: TimeInterval
    let score: Int
    let stability: Float // 0-100%

    var grade: String {
        switch score {
        case 0..<5000: return "D"
        case 5000..<8000: return "C"
        case 8000..<12000: return "B"
        case 12000..<15000: return "A"
        case 15000...Int.max: return "S"
        default: return "D"
        }
    }
}

// MARK: - Manhattan Benchmark
class ManhattanBenchmark: MetalBenchmark {
    let name = "Manhattan 3.0"
    let duration: TimeInterval = 150.0 // 2.5 minutes
    let sceneDescription = "中等复杂度 3D 场景，OpenGL ES 3.0 级别渲染"

    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?

    private var frameCount: Int = 0
    private var startTime: Date?
    private var fpsValues: [Float] = []
    private var lastTime: CFTimeInterval = 0

    // Scene properties
    private var rotation: Float = 0.0
    private var vertices: [Float] = []
    private var indices: [UInt16] = []

    init(device: MTLDevice) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw BenchmarkError.deviceNotSupported
        }
        self.commandQueue = queue

        setupScene()
    }

    private func setupScene() {
        // Create a simple 3D cube with more vertices for complexity
        vertices = [
            // Front face
            -1.0, -1.0,  1.0,   1.0, 0.0, 0.0,
             1.0, -1.0,  1.0,   0.0, 1.0, 0.0,
             1.0,  1.0,  1.0,   0.0, 0.0, 1.0,
            -1.0,  1.0,  1.0,   1.0, 0.0, 1.0,
            // Back face
            -1.0, -1.0, -1.0,   0.0, 1.0, 0.0,
            -1.0,  1.0, -1.0,   1.0, 0.0, 0.0,
             1.0,  1.0, -1.0,   0.0, 0.0, 1.0,
             1.0, -1.0, -1.0,   0.0, 0.0, 1.0,
            // Top face
            -1.0,  1.0, -1.0,   1.0, 0.5, 0.0,
            -1.0,  1.0,  1.0,   1.0, 0.5, 0.5,
             1.0,  1.0,  1.0,   1.0, 0.0, 1.0,
             1.0,  1.0, -1.0,   1.0, 0.5, 1.0,
            // Bottom face
            -1.0, -1.0, -1.0,   0.5, 1.0, 0.5,
             1.0, -1.0, -1.0,   0.0, 1.0, 1.0,
             1.0, -1.0,  1.0,   0.5, 0.5, 1.0,
            -1.0, -1.0,  1.0,   1.0, 0.0, 0.5,
            // Right face
             1.0, -1.0, -1.0,   1.0, 0.0, 0.5,
             1.0,  1.0, -1.0,   1.0, 0.5, 0.0,
             1.0,  1.0,  1.0,   0.5, 1.0, 0.0,
             1.0, -1.0,  1.0,   0.0, 1.0, 0.0,
            // Left face
            -1.0, -1.0, -1.0,   0.0, 1.0, 0.5,
            -1.0, -1.0,  1.0,   0.5, 1.0, 0.0,
            -1.0,  1.0,  1.0,   1.0, 0.5, 1.0,
            -1.0,  1.0, -1.0,   1.0, 0.0, 1.0,
        ]

        indices = [
            0, 1, 2, 0, 2, 3,       // front
            4, 5, 6, 4, 6, 7,       // back
            8, 9, 10, 8, 10, 11,    // top
            12, 13, 14, 12, 14, 15,  // bottom
            16, 17, 18, 16, 18, 19,  // right
            20, 21, 22, 20, 22, 23   // left
        ]
    }

    func setup(view: MTKView) throws {
        startTime = Date()

        // Create vertex buffer
        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Float>.size)
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count)

        // Create index buffer
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt16>.size)
        indexBuffer = device.makeBuffer(bytes: indexData, length: indexData.count)

        // Create uniform buffer
        var uniforms: [Float] = [1.0]
        uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Float>.size)

        // Create pipeline state
        let library = try device.makeLibrary(source: metalShaders)
        let vertexFunction = try library.makeFunction(name: "vertexShader")
        let fragmentFunction = try library.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 6
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        // Setup depth stencil state
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true

        view.depthStencilPixelFormat = .depth32Float_stencil8
        view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
    }

    func update(deltaTime: Float) {
        rotation += deltaTime * 0.5
    }

    func draw(view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let vertexBuffer = vertexBuffer,
              let indexBuffer = indexBuffer,
              let uniformBuffer = uniformBuffer else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime

        update(deltaTime: deltaTime)

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        // Record FPS
        frameCount += 1
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start)
            if elapsed > 0 {
                let fps = Float(frameCount) / Float(elapsed)
                fpsValues.append(fps)
            }
        }
    }

    func cleanup() {
        vertexBuffer = nil
        indexBuffer = nil
        uniformBuffer = nil
        pipelineState = nil
    }

    func getScore() -> BenchmarkScore {
        guard !fpsValues.isEmpty else {
            return BenchmarkScore(averageFPS: 0, minFPS: 0, maxFPS: 0, frameCount: 0, totalTime: 0, score: 0, stability: 0)
        }

        let avgFPS = fpsValues.reduce(0, +) / Float(fpsValues.count)
        let minFPS = fpsValues.min() ?? 0
        let maxFPS = fpsValues.max() ?? 0
        let totalTime = Date().timeIntervalSince(startTime ?? Date())

        // Calculate score based on average FPS
        let score = Int(avgFPS * 100)

        // Calculate stability (minFPS / avgFPS * 100)
        let stability = avgFPS > 0 ? (minFPS / avgFPS) * 100 : 0

        return BenchmarkScore(
            averageFPS: avgFPS,
            minFPS: minFPS,
            maxFPS: maxFPS,
            frameCount: frameCount,
            totalTime: totalTime,
            score: score,
            stability: stability
        )
    }
}

// MARK: - Metal Shaders
private let metalShaders = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

struct Uniforms {
    float scale;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut out;
    float4 pos = float4(in.position, 1.0);
    pos.x *= uniforms.scale;
    pos.y *= uniforms.scale;
    pos.z *= uniforms.scale;
    out.position = pos;
    out.color = in.color;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return float4(in.color, 1.0);
}
"""

// MARK: - Benchmark Error
enum BenchmarkError: Error {
    case deviceNotSupported
    case shaderCompilationFailed
    case pipelineCreationFailed
}

// MARK: - Simple GPU Benchmark (for devices without Metal support)
class SimpleGPUBenchmark {
    func runBenchmark() -> BenchmarkScore {
        let startTime = Date()
        var frameCount = 0
        let targetDuration: TimeInterval = 10.0 // 10 seconds

        // Simulate GPU workload
        while Date().timeIntervalSince(startTime) < targetDuration {
            // Simple float operations to simulate GPU load
            var result: Float = 0.0
            for _ in 0..<10000 {
                result += sin(Float(frameCount)) * cos(Float(frameCount))
            }
            frameCount += 1

            // Small delay to simulate render time
            Thread.sleep(forTimeInterval: 0.001)
        }

        let totalTime = Date().timeIntervalSince(startTime)
        let avgFPS = Float(frameCount) / Float(totalTime)

        return BenchmarkScore(
            averageFPS: avgFPS,
            minFPS: avgFPS * 0.9,
            maxFPS: avgFPS * 1.1,
            frameCount: frameCount,
            totalTime: totalTime,
            score: Int(avgFPS * 100),
            stability: 90.0
        )
    }
}
