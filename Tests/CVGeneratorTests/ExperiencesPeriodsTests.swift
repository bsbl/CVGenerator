//
//  ExperiencesPeriodsTests.swift
//  CVGenerator
//
//  Created by bsbl on 01.03.20.
//

import Foundation
import XCTest

class ExperiencesPeriodsTests: XCTestCase {
    var formatter: DateFormatter?
    var expN: ExperiencePeriod?
    var expN_1: ExperiencePeriod?
    var expN_2: ExperiencePeriod?
    
    let weights = [
        6.18046971569839,
        5.2109659685335,
        4.77299343771778,
        4.50438278202489,
        4.31598164036902,
        4.17335925618173,
        4.05992771604906
    ]
    
    override func setUp() {
        let now = Date()
        let start1 = Calendar.current.date(byAdding: .month, value: -12, to: now)!
        expN = ExperiencePeriod(from: start1, to: now, technos: ["A","B","C"])
        let start2 = Calendar.current.date(byAdding: .month, value: -24, to: start1)!
        expN_1 = ExperiencePeriod(from: start2, to: start1, technos: ["B","D","A","E"])
        let start3 = Calendar.current.date(byAdding: .month, value: -12, to: start2)!
        expN_2 = ExperiencePeriod(from: start3, to: start2, technos: ["B","A","D","E"])
    }
    
    func testSingleExperience() {
        var exps = ExperiencesPeriods()
        exps.add(expN!)
        let techs = exps.orderedTechnos()
        XCTAssertEqual("A", techs[0])
        XCTAssertEqual("B", techs[1])
        XCTAssertEqual("C", techs[2])
    }

    /*
     36 -> 36;25 ((36/36)+(25/36))/2 x 12 = 10.16
            A = x 6.18 = 62,7888
            B = x 5.21 = 52,9336
            C = x 4.77 = 48,4632
           24;1  ((24/36)+(1/36)) /2 x 24 =  8.33
            B = x 6.18 = 51,4794
            D = x 5.21 = 43,3993
            A = x 4.77 = 39,7341
            E = x 4.50 = 37,485
          
           Sum(B) = 104,413
           Sum(A) = 102,5229
           Sum(C) = 48,4632
           Sum(D) = 43,3993
           Sum(E) = 37,485
     */
    func testDualExperience() {
        var exps = ExperiencesPeriods()
        exps.add(expN!)
        exps.add(expN_1!)
        let techs = exps.orderedTechnos()
        
        XCTAssertEqual("B", techs[0])
        XCTAssertEqual("A", techs[1])
        XCTAssertEqual("C", techs[2])
        XCTAssertEqual("D", techs[3])
        XCTAssertEqual("E", techs[4])
    }

    /*
           Sum(B) = 141,120530720984
           Sum(A) = 132,604480040205
           Sum(D) = 71,5904474508268
           Sum(E) = 62,4983111005953
           Sum(C) = 50,7130552757514
     */
    func test3Experiences() {
        var exps = ExperiencesPeriods()
        exps.add(expN!)
        exps.add(expN_1!)
        exps.add(expN_2!)
        let techs = exps.orderedTechnos()
        
        XCTAssertEqual("B", techs[0])
        XCTAssertEqual("A", techs[1])
        XCTAssertEqual("D", techs[2])
        XCTAssertEqual("E", techs[3])
        XCTAssertEqual("C", techs[4])
    }

}
