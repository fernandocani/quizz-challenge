import Foundation

class SettingsBundleHelper {
    
    static let shared = SettingsBundleHelper()
    
    struct SettingsBundleKeys {
        static let delay = "delay_preference"
    }
    
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.delay) {
            
        }
    }
    
}
