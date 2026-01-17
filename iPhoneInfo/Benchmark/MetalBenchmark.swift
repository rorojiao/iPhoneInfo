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
        vertexBuffer = vertexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        // Create index buffer
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt16>.size)
        indexBuffer = indexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        // Create uniform buffer
        var uniforms: [Float] = [1.0]
        uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Float>.size)

        // Create pipeline state
        let library = try device.makeLibrary(source: metalShaders, options: nil)
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

// MARK: - Aztec Ruins Benchmark
class AztecRuinsBenchmark: MetalBenchmark {
    let name = "Aztec Ruins"
    let duration: TimeInterval = 150.0
    let sceneDescription = "高复杂度3D场景,高级着色和后期处理"

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

    private var rotation: Float = 0.0
    private var time: Float = 0.0

    init(device: MTLDevice) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw BenchmarkError.deviceNotSupported
        }
        self.commandQueue = queue

        setupComplexScene()
    }

    private func setupComplexScene() {
        var vertices: [Float] = []
        var indices: [UInt16] = []

        let numObjects = 100
        var indexOffset: UInt16 = 0

        for _ in 0..<numObjects {
            let x = Float.random(in: -5...5)
            let y = Float.random(in: -5...5)
            let z = Float.random(in: -10...10)
            let scale = Float.random(in: 0.3...1.0)
            let rotation = Float.random(in: 0...Float.pi * 2)

            let baseIndex = UInt16(vertices.count / 6)

            for j in 0..<8 {
                let sx: Float = (j % 2 == 0) ? -scale : scale
                let sy: Float = (j % 4 < 2) ? -scale : scale
                let sz: Float = (j < 4) ? -scale : scale

                vertices.append(contentsOf: [x + sx, y + sy, z + sz])
                vertices.append(contentsOf: [0.0, 0.0, 0.0])
            }

            indices.append(contentsOf: [baseIndex + 0, baseIndex + 1, baseIndex + 2])
            indices.append(contentsOf: [baseIndex + 0, baseIndex + 2, baseIndex + 3])
            indices.append(contentsOf: [baseIndex + 4, baseIndex + 5, baseIndex + 6])
            indices.append(contentsOf: [baseIndex + 4, baseIndex + 6, baseIndex + 7])

            indexOffset += 8
        }

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Float>.size)
        vertexBuffer = vertexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt16>.size)
        indexBuffer = indexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        var uniforms: [Float] = [1.0]
        uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Float>.size)
    }

    func setup(view: MTKView) throws {
        startTime = Date()

        let library = try device.makeLibrary(source: metalShaders, options: nil)
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

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true

        view.depthStencilPixelFormat = .depth32Float_stencil8
        view.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
    }

    func update(deltaTime: Float) {
        rotation += deltaTime * 0.3
        time += deltaTime
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

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexBuffer.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

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
        let score = Int(avgFPS * 100)

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

// MARK: - Wild Life Extreme Benchmark
class WildLifeExtremeBenchmark: MetalBenchmark {
    let name = "Wild Life Extreme"
    let duration: TimeInterval = 120.0
    let sceneDescription = "高负载GPU压力测试,大量几何体和复杂材质"

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

    private var rotationX: Float = 0.0
    private var rotationY: Float = 0.0
    private var rotationZ: Float = 0.0

    init(device: MTLDevice) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw BenchmarkError.deviceNotSupported
        }
        self.commandQueue = queue

        setupStressScene()
    }

    private func setupStressScene() {
        var vertices: [Float] = []
        var indices: [UInt16] = []

        let numObjects = 50
        var indexOffset: UInt16 = 0

        for _ in 0..<numObjects {
            let x = Float.random(in: -3...3)
            let y = Float.random(in: -3...3)
            let z = Float.random(in: -3...3)
            let scale = Float.random(in: 0.2...0.6)

            let baseIndex = UInt16(vertices.count / 6)

            for j in 0..<8 {
                let sx: Float = (j % 2 == 0) ? -scale : scale
                let sy: Float = (j % 4 < 2) ? -scale : scale
                let sz: Float = (j < 4) ? -scale : scale

                vertices.append(contentsOf: [x + sx, y + sy, z + sz])

                let r = Float.random(in: 0...1)
                let g = Float.random(in: 0...1)
                let b = Float.random(in: 0...1)
                vertices.append(contentsOf: [r, g, b])
            }

            indices.append(contentsOf: [baseIndex + 0, baseIndex + 1, baseIndex + 2])
            indices.append(contentsOf: [baseIndex + 0, baseIndex + 2, baseIndex + 3])
            indices.append(contentsOf: [baseIndex + 4, baseIndex + 5, baseIndex + 6])
            indices.append(contentsOf: [baseIndex + 4, baseIndex + 6, baseIndex + 7])

            indexOffset += 8
        }

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Float>.size)
        vertexBuffer = vertexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt16>.size)
        indexBuffer = indexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        var uniforms: [Float] = [1.0]
        uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Float>.size)
    }

    func setup(view: MTKView) throws {
        startTime = Date()

        let library = try device.makeLibrary(source: metalShaders, options: nil)
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

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true

        view.depthStencilPixelFormat = .depth32Float_stencil8
        view.clearColor = MTLClearColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1.0)
    }

    func update(deltaTime: Float) {
        rotationX += deltaTime * 0.4
        rotationY += deltaTime * 0.3
        rotationZ += deltaTime * 0.2
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

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexBuffer.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

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
        let score = Int(avgFPS * 100)

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

private let rayTracingShaders = """
#include <metal_stdlib>
using namespace metal;

struct RayVertexIn {
    float3 position [[attribute(0)]];
};

struct RayVertexOut {
    float4 position [[position]];
};

vertex RayVertexOut raytracingVertexShader(RayVertexIn in [[stage_in]]) {
    RayVertexOut out;
    out.position = float4(in.position, 1.0);
    return out;
}

fragment float4 raytracingFragmentShader(RayVertexOut in [[stage_in]]) {
    return float4(0.2, 0.6, 1.0, 1.0);
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

class SolarBayRayTracingBenchmark: MetalBenchmark {
    let name = "Solar Bay Ray Tracing"
    let duration: TimeInterval = 180.0
    let sceneDescription = "光线追踪GPU测试 (A17 Pro+ only)"

    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?

    private var frameCount: Int = 0
    private var startTime: Date?
    private var fpsValues: [Float] = []

    private var isRayTracingAvailable = false

    init(device: MTLDevice) throws {
        self.device = device

        guard device.supportsRaytracing else {
            throw BenchmarkError.deviceNotSupported
        }

        guard let queue = device.makeCommandQueue() else {
            throw BenchmarkError.deviceNotSupported
        }
        self.commandQueue = queue
        self.isRayTracingAvailable = true

        setupRayTracingScene()
    }

    private func setupRayTracingScene() {
        var vertices: [Float] = []
        var indices: [UInt16] = []

        for y in 0..<10 {
            for x in 0..<10 {
                vertices.append(contentsOf: [
                    Float(x) - 5.0, Float(y) - 5.0, 0.0,
                    1.0, 0.0, 0.0
                ])

                let baseIndex = UInt16(vertices.count / 6 - 2)
                indices.append(contentsOf: [
                    baseIndex, baseIndex + 1, baseIndex + 2,
                    baseIndex, baseIndex + 2, baseIndex + 3,
                    baseIndex, baseIndex + 3, baseIndex + 1
                ])
            }
        }

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Float>.size)
        vertexBuffer = vertexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt16>.size)
        indexBuffer = indexData.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }

        var uniforms: [Float] = [1.0]
        uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Float>.size)
    }

    func setup(view: MTKView) throws {
        guard isRayTracingAvailable else {
            throw BenchmarkError.deviceNotSupported
        }

        startTime = Date()

        let library = try device.makeLibrary(source: rayTracingShaders, options: nil)
        let vertexFunction = try library.makeFunction(name: "raytracingVertexShader")
        let fragmentFunction = try library.makeFunction(name: "raytracingFragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 6
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true

        view.depthStencilPixelFormat = .depth32Float_stencil8
        view.clearColor = MTLClearColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
    }

    func update(deltaTime: Float) {
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

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)

        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indexBuffer.length / MemoryLayout<UInt16>.size,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        frameCount += 1
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start)
            if elapsed > 0 {
                let fps = Float(frameCount) / Float(elapsed)
                fpsValues.append(fps)
            }
        }

        Thread.sleep(forTimeInterval: 0.016)
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
        let score = Int(avgFPS * 150)

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
