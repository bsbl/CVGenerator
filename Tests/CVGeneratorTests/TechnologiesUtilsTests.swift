//
//  TechnologiesUtilsTests.swift
//  CVGeneratorTests
//
//  Created by bsbl on 10.03.20.
//

import Foundation
import XCTest

class TechnologiesUtilsTests: XCTestCase {
    
    func testTechnologiesListNormalization() {
        let techs = "Spring boot, java8, Java 7, Spring 3-4, Linux 6-7, Akka 2.x, Oracle (spatial cartridge), git, Cloud-Foundry."
        let normalizedTechs = TechnologiesUtils.normalizeRawTechnos(techs)
        XCTAssertEqual(7, normalizedTechs.count)
        XCTAssertEqual("Spring", normalizedTechs[0])
        XCTAssertEqual("Java", normalizedTechs[1])
        XCTAssertEqual("Linux", normalizedTechs[2])
        XCTAssertEqual("Akka", normalizedTechs[3])
        XCTAssertEqual("Oracle", normalizedTechs[4])
        XCTAssertEqual("Git", normalizedTechs[5])
        XCTAssertEqual("Cloud-Foundry", normalizedTechs[6])
    }
    
}
