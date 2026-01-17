//
//  SensorService.swift
//  iPhoneInfo
//
//  Sensor data collection service
//

import Foundation
import CoreMotion
import Combine

class SensorService: ObservableObject {
    static let shared = SensorService()

    @Published var accelerometerData: AccelerometerData?
    @Published var gyroscopeData: GyroscopeData?
    @Published var magnetometerData: MagnetometerData?

    private var motionManager: CMMotionManager
    private var cancellable: AnyCancellable?

    private init() {
        motionManager = CMMotionManager()
    }

    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable ||
              motionManager.isGyroAvailable ||
              motionManager.isMagnetometerAvailable else {
            return
        }

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0
            motionManager.startAccelerometerUpdates(to: .main, withHandler: { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.accelerometerData = AccelerometerData(
                    x: data.acceleration.x,
                    y: data.acceleration.y,
                    z: data.acceleration.z,
                    timestamp: Date()
                )
            })
        }

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0
            motionManager.startGyroUpdates(to: .main, withHandler: { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.gyroscopeData = GyroscopeData(
                    x: data.rotationRate.x,
                    y: data.rotationRate.y,
                    z: data.rotationRate.z,
                    timestamp: Date()
                )
            })
        }

        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 2.0
            motionManager.startMagnetometerUpdates(to: .main, withHandler: { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.magnetometerData = MagnetometerData(
                    x: data.magneticField.x,
                    y: data.magneticField.y,
                    z: data.magneticField.z,
                    timestamp: Date()
                )
            })
        }
    }

    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
    }

    func getSensorAvailability() -> SensorAvailability {
        return SensorAvailability(
            accelerometerAvailable: motionManager.isAccelerometerAvailable,
            gyroscopeAvailable: motionManager.isGyroAvailable,
            magnetometerAvailable: motionManager.isMagnetometerAvailable
        )
    }
}

struct AccelerometerData {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: Date

    var magnitude: Double {
        return sqrt(x * x + y * y + z * z)
    }

    var formattedMagnitude: String {
        let value = magnitude
        if value < 0.3 {
            return "静止"
        } else if value < 1.0 {
            return "轻微移动"
        } else if value < 2.0 {
            return "中等移动"
        } else {
            return "剧烈移动"
        }
    }
}

struct GyroscopeData {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: Date

    var totalRotationRate: Double {
        return sqrt(x * x + y * y + z * z)
    }
}

struct MagnetometerData {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: Date

    var magneticFieldStrength: Double {
        return sqrt(x * x + y * y + z * z)
    }

    var heading: Double {
        return atan2(y, x) * 180 / .pi
    }

    var formattedHeading: String {
        let headingInt = Int(heading)
        return String(format: "%.0f°", headingInt)
    }
}

struct SensorAvailability {
    let accelerometerAvailable: Bool
    let gyroscopeAvailable: Bool
    let magnetometerAvailable: Bool

    var allAvailable: Bool {
        accelerometerAvailable && gyroscopeAvailable && magnetometerAvailable
    }
}
