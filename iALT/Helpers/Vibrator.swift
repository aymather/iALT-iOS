import Foundation
import CoreHaptics

public class Vibrator {
    
    /// Indicates if the device supports haptic event playback.
    public let supportsHaptics: Bool = {
        print("Supports haptics: \(CHHapticEngine.capabilitiesForHardware().supportsHaptics)")
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    
    private var player: CHHapticAdvancedPatternPlayer?
    private var engine: CHHapticEngine?
    
    private var start: Date?
    
    // MARK: - Init
    init() {
        guard supportsHaptics else { return }
        engine = try? CHHapticEngine()
    }
    
    /// Prepares the vibrator by acquiring hardware needed for vibrations.
    public func prepare() {
        guard let engine: CHHapticEngine = engine else { return }
        
        try? engine.start()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.2)
        let pattern = try? CHHapticPattern(events: [event], parameters: [])
        self.player = try? engine.makeAdvancedPlayer(with: pattern!)
    }
    
    /// Stop haptic player
    public func stopHaptic() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
    }
    
    /// Play haptic event for 1 second
    @objc func play() {
        
        self.start = Date()
        try? self.player?.start(atTime: 0)
        
    }
    
}

