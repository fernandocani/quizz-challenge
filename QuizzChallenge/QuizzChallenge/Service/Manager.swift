import UIKit

class Manager {

    static let url = "https://codechallenge.arctouch.com/quiz/1"
 
    static func loadJson(filename: String) -> Quizz? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quizz = try decoder.decode(Quizz.self, from: data)
                return quizz
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    static func loadRequest(callbackSuccess: @escaping ((_ quizz: Quizz)->Void), callbackError: @escaping (()->Void)) {
        guard let url = URL(string: Manager.url) else { callbackError(); return }
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let task = URLSession.init(configuration: config).dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                switch resp.statusCode {
                case 200:
                    guard let dt = data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let quizz = try decoder.decode(Quizz.self, from: dt)
                        if UserDefaults.standard.bool(forKey: "delay_preference") {
                            sleep(3)
                        }
                        callbackSuccess(quizz)
                    } catch {
                        callbackError()
                    }
                default:
                    callbackError()
                }
            } else {
                callbackError()
            }
        }
        task.resume()
    }
    
}
