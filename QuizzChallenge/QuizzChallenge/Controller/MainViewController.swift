import UIKit

class MainViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnStartReset: UIButton!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var viewLoadingBG: UIView!
    
    // MARK: - Variables
    var quizz: Quizz = Quizz() {
        didSet {
            if let question = self.quizz.question {
                self.lblTitle.isHidden = false
                DispatchQueue.main.async {
                    self.lblTitle.text = question
                }
            } else {
                self.lblTitle.isHidden = true
            }
            if let answer = self.quizz.answer {
                self.answer = answer
            }
        }
    }
    var answer: [String] = [] {
        willSet {
            self.answer.removeAll()
        }
        didSet {
            DispatchQueue.main.async {
                self.lblQuestion.text = "\(self.questions.withZero())/\(self.answer.count.withZero())"
            }
        }
    }
    var questions: Int = 0 {
        didSet {
            self.lblQuestion.text = "\(self.questions.withZero())/\(self.answer.count.withZero())"
            if self.answer.count > 0 && self.questions >= self.answer.count {
                self.pauseTimer()
                self.feedback.notificationOccurred(.error)
                self.addAlert(title: "Congratulations",
                              message: "Good job! You found all the anwsers on time. Keep up with the great work.",
                              actionOkTitle: "Play Again",
                              actionOkHandler: { (_) in
                                self.resetTimer()
                })
            }
        }
    }
    var strings: [String] = [] {
        didSet {
            self.tableView.reloadData()
            self.questions = self.strings.count
            self.txtInput.text = String()
        }
    }
    var defaultTimer: Int = 300
    var seconds: Int = Int() {
        didSet {
            self.lblTime.text = TimeInterval(self.seconds).toTimeString()
            if self.seconds > 5 {
                self.impact.impactOccurred()
            } else if self.seconds <= 5 && self.seconds > 0 {
                self.feedback.notificationOccurred(.warning)
            } else if self.seconds == 0 {
                self.feedback.notificationOccurred(.error)
                self.pauseTimer()
                self.addAlert(title: "Time finished",
                              message: "Sorry, time is up! You got \(self.questions.withZero()) out of \(self.answer.count) anwsers.",
                    actionOkTitle: "Try Again",
                    actionOkHandler: { (_) in
                        self.resetTimer()
                })
            }
        }
    }
    var timer = Timer()
    var isTimerRunning = false {
        didSet {
            self.txtInput.isUserInteractionEnabled = self.isTimerRunning
        }
    }
    var loading: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.viewLoading.isHidden = !self.loading
            }
        }
    }
    let feedback: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    let impact: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    // MARK: - Init
    required init() {
        super.init(nibName: "MainViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
        self.setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadQuizz()
    }
    
    func prepareView() {
        self.loading = false
        self.lblTitle.isHidden = true
        self.tableView.isHidden = true
        self.txtInput.isHidden = true
        self.viewLoading.isHidden = true
        self.isTimerRunning = false
        self.questions = 0
        self.seconds = self.defaultTimer
        self.feedback.prepare()
        self.impact.prepare()
    }
    
    func setLayout() {
        self.btnStartReset.layer.cornerRadius = 4
        self.btnStartReset.layer.masksToBounds = true
        self.txtInput.layer.borderWidth = 0
        self.txtInput.layer.borderColor = UIColor.clear.cgColor
        self.txtInput.addTarget(self, action: #selector(editingChanged), for: UIControl.Event.editingChanged)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.viewLoadingBG.layer.cornerRadius = 10
        self.viewLoadingBG.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func loadQuizz(fake: Bool = false) {
        self.loading = true
        if fake {
            if let quizz = Manager.loadJson(filename: "quizz") {
                self.loading = false
                self.lblTitle.isHidden = self.loading
                self.txtInput.isHidden = self.loading
                self.tableView.isHidden = self.loading
                self.quizz = quizz
            }
        } else {
            Manager.loadRequest(callbackSuccess: { (quizz) in
                self.loading = false
                self.lblTitle.isHidden = self.loading
                self.txtInput.isHidden = self.loading
                self.tableView.isHidden = self.loading
                self.quizz = quizz
            }) {
                self.loading = false
                self.addAlert(title: "Atention",
                              message: "Request failed.",
                              actionOkTitle: "Try again",
                              actionOkHandler: { (_) in self.loadQuizz() },
                              actionCancelTitle: "Load offline",
                              actionCancelHandler: { (_) in self.loadQuizz(fake: true)})
            }
        }
    }
    
    @IBAction func btnStartReset(_ sender: UIButton) {
        if self.isTimerRunning {
            self.feedback.notificationOccurred(.error)
            self.resetTimer()
        } else {
            self.feedback.notificationOccurred(.success)
            self.runTimer()
        }
    }
    
}

// MARK: - TableView
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.strings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.strings[indexPath.row]
        return cell
    }
    
}

// MARK: - TextField
extension MainViewController: UITextFieldDelegate {
    
    @objc
    func editingChanged() {
        guard let string = self.txtInput.text else { return }
        if !self.strings.contains(string) && self.answer.contains(string) {
            self.strings.append(string)
            self.feedback.notificationOccurred(.success)
        }
    }
    
}

// MARK: - Timer
extension MainViewController {
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(MainViewController.updateTimer),
                                          userInfo: nil,
                                          repeats: true)
        self.isTimerRunning = true
        self.btnStartReset.setTitle("Reset", for: .normal)
        self.txtInput.becomeFirstResponder()
        self.lblTime.alpha = 0.3
        UIView.animate(withDuration: 0.5,
                       delay: 0.5,
                       options: [.curveLinear, .repeat, .autoreverse],
                       animations: {self.lblTime.alpha = 1.0},
                       completion: nil)
    }
    
    @objc
    func updateTimer() {
        self.seconds -= 1
    }
    
    func pauseTimer() {
        self.timer.invalidate()
        self.lblTime.layer.removeAllAnimations()
        self.txtInput.resignFirstResponder()
    }
    
    func resetTimer() {
        self.timer.invalidate()
        self.lblTime.layer.removeAllAnimations()
        self.seconds = self.defaultTimer
        self.isTimerRunning = false
        self.btnStartReset.setTitle("Start", for: .normal)
        self.strings.removeAll()
        self.txtInput.resignFirstResponder()
    }
    
}
