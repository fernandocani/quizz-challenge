import UIKit

extension TimeInterval {
    
    func toTimeString() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
}

extension Int {
    
    func withZero() -> String {
        return String(format:"%02i", self)
    }
    
}
