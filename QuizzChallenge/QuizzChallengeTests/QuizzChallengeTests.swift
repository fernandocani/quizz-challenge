//
//  QuizzChallengeTests.swift
//  QuizzChallengeTests
//
//  Created by Fernando Lemler Cani on 17/01/20.
//  Copyright © 2020 Fernando Lemler Cani. All rights reserved.
//

import XCTest
@testable import QuizzChallenge

class QuizzChallengeTests: XCTestCase {

    let controller: MainViewController = MainViewController()
    
    override func setUp() {
        self.controller.loadViewIfNeeded()
        self.controller.loadQuizz(fake: true)
    }

    override func tearDown() {
        self.controller.strings.removeAll()
        self.controller.answer.removeAll()
        
    }

    func test1() {
        self.controller.strings = []
        self.controller.txtInput.text = "do"
        self.controller.editingChanged()
        XCTAssert(self.controller.strings.count == 1)
    }
    
    func test2() {
        self.controller.strings = ["do"]
        self.controller.txtInput.text = "do"
        self.controller.editingChanged()
        XCTAssert(self.controller.strings.count == 1)
    }
    
    func test3() {
        self.controller.strings = ["do"]
        self.controller.txtInput.text = "catch"
        self.controller.editingChanged()
        XCTAssert(self.controller.strings.count == 2)
    }
    
    func test4() {
        self.controller.questions = 4
        XCTAssertTrue(self.controller.lblQuestion.text == "04/\(self.controller.answer.count.withZero())")
    }
    
    func test5() {
        self.controller.questions = 4
        XCTAssertFalse(self.controller.lblQuestion.text == "05/\(self.controller.answer.count.withZero())")
    }
    
    func test6() {
        self.controller.seconds = 1
        self.controller.updateTimer()
        XCTAssertTrue(self.controller.seconds == 0)
    }
    
    func test7() {
        self.controller.quizz = Quizz(question: nil, answer: nil)
        XCTAssertTrue(self.controller.lblTitle.isHidden)
    }
    
    func test8() {
        self.controller.questions = 50
        XCTAssertFalse(self.controller.timer.isValid)
    }
    
    func test9() {
        self.controller.isTimerRunning = false
        self.controller.btnStartReset(self.controller.btnStartReset)
        XCTAssertTrue(self.controller.timer.isValid)
    }
    
    func test10() {
        self.controller.isTimerRunning = true
        self.controller.btnStartReset(self.controller.btnStartReset)
        XCTAssertFalse(self.controller.timer.isValid)
    }
    
    func test11() {
        let json = Manager.loadJson(filename: "quizz")
        XCTAssertNotNil(json)
    }
    
    func test12() {
        let json = Manager.loadJson(filename: "invalid_file")
        XCTAssertNil(json)
    }

}
