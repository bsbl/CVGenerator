//
//  CVSourceSectionItemTests.swift
//  CVGenerator
//
//  Created by bsbl on 12.02.20.
//

import Foundation

import XCTest

class CVResumeGeneratorTests: XCTestCase {
    
    var source: CVSource?
    var parser: CVTemplateParser?
    
    override func setUp() {
        do {
            let source = CVSource()
            try source.load(excelSource: "/Users/sbl/Documents/Latex/resume-genetator/CVGenerator/Tests/CVGeneratorTests/datasource1.xlsx")
            self.source = source

            let parser = try CVTemplateParser(applicationName: "solution_architect", translations: source.dataSourceVariables ?? [:], skippedSections: [])
            self.parser = parser
            try parser.loadTemplate(template: "/Users/sbl/Documents/Latex/resume-genetator/CVGenerator/Tests/CVGeneratorTests/template.tex")
        } catch {
            print("Test failed with error: \(error).")
            XCTFail()
        }
    }

    
    func testGenerateDoc() {
        injectSectionsAndAssert()
        substituteVarsAndAssert()
    }
    
    func substituteVarsAndAssert() {
        let variables = source?.standardVariables(lang: "fr", applicationName: "solution_architect") ?? [:]
        parser?.substituteVariables(variables: variables)
        XCTAssertTrue(parser?.resumeContent?[122].contains(variables[.email] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[122].contains(variables[.phone] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[122].contains(variables[.place] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[180].contains(variables[.name] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[182].contains(variables[.jobTitle] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[188].contains(variables[.email] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[188].contains(variables[.phone] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[188].contains(variables[.linkedIn] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[188].contains(variables[.github] ?? "¥") ?? false)
        XCTAssertTrue(parser?.resumeContent?[193].contains(variables[.jobSummary] ?? "¥") ?? false)
    }
    
    func injectSectionsAndAssert() {
        let sections = source?.dataSourceSections ?? [:]
        parser?.injectSections(sections: sections, lang: "fr")
        // strengths
        XCTAssertTrue((parser?.resumeContent?[205] ?? "").contains("\\strength{Communication}"))
        XCTAssertTrue((parser?.resumeContent?[205] ?? "").contains("\\strength{Architecture}"))
        // education & certifications
        XCTAssertTrue((parser?.resumeContent?[207] ?? "").contains("\\certificate{Titre de mon diplôme}{Mon école ou université}{2005}"))
        XCTAssertTrue((parser?.resumeContent?[207] ?? "").contains("\\certification{Certification de Scrum Product Owner}{}{2010}"))
        XCTAssertTrue((parser?.resumeContent?[207] ?? "").contains("\\certification{Programmation fonctionnelle en Scala}{Coursera / EPFL}{2013}"))
        // languages:
        XCTAssertTrue((parser?.resumeContent?[209] ?? "").contains("\\langLevel{Français}{Langue maternelle}"))
        XCTAssertTrue((parser?.resumeContent?[209] ?? "").contains("\\langLevel{Anglais}{Lu, écrit et parlé}"))
        // Technologies
        /// TODO SBL compute technologies list
        XCTAssertTrue( (parser?.resumeContent?[211] ?? "").contains("\\section{Technologies}\nLorem • Consectetur • Cras • Non"))

        // experience
        XCTAssertTrue( (parser?.resumeContent?[220] ?? "").contains("\\experience{Leader technique}{Compagnie 2 • Domaine d’activité}{nov. 2018"))
        XCTAssertTrue((parser?.resumeContent?[220] ?? "").contains("}{Genève}{"))
        XCTAssertTrue((parser?.resumeContent?[220] ?? "").contains("\\begin{itemize}\\item Curabitur euismod scelerisque arcu sit amet pulvinar"))
        XCTAssertTrue((parser?.resumeContent?[220] ?? "").contains("end{itemize}}{Lorem ipsum dolor sit amet, consectetur adipiscing elit}"))

    }
}
