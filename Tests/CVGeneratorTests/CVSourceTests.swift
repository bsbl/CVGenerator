//
//  CVSourceTests.swift
//  CVGenerator
//
//  Created by bsbl on 14.02.20.
//

import Foundation
import XCTest

class CVSourceTests: XCTestCase {
    
    var source: CVSource?
    
    override func setUp() {
        do {
            let source = CVSource()
            let bundle = Bundle(for: type(of: self))
            let xlsxPath = bundle.path(forResource: "datasource1", ofType: "xlsx")!
            try source.load(excelSource: xlsxPath)
            self.source = source
        } catch {
            print("Test failed with error: \(error).")
            XCTFail()
        }
    }
    
    func testParser() {
        assertVariableParser()
        assertStrengthsSection()
        assertSections()
        assertLanguageSection()
        assertEducationAndCertificationSection()
        assertExperienceSection()
        assertTechnologiesSection()
    }
    
    func assertVariableParser() {
        // ----------
        // variables checks:
        XCTAssertEqual(14, source?.dataSourceVariables?.count)
        
        let cd = source?.dataSourceVariables
        let emptyValuesFr = cd?["fr"]?.filter { $0.value == "" }.map { $0.key } ?? []
        XCTAssertTrue(emptyValuesFr.isEmpty, "Nil or empty values in variables: \(emptyValuesFr)")
        let emptyValuesEn = cd?["en"]?.filter { $0.value == "" }.map { $0.key } ?? []
        XCTAssertTrue(emptyValuesEn.isEmpty, "Nil or empty values in variables: \(emptyValuesEn)")
        
        //
        XCTAssertEqual(source?.dataSourceVariables?["JOBTITLE"]?["fr"], "Ingénieur de développement")
        XCTAssertEqual(source?.dataSourceVariables?["section_experience"]?["fr"], "Expériences professionnelles")
        XCTAssertEqual(source?.dataSourceVariables?["section_education_\\&_certifications"]?["fr"], "Education \\& Certifications")
        XCTAssertEqual(source?.dataSourceVariables?["section_languages"]?["fr"], "Langues")
        XCTAssertEqual(source?.dataSourceVariables?["section_strengths"]?["fr"], "Atouts")
        XCTAssertEqual(source?.dataSourceVariables?["coordonnees"]?["fr"], "Coordonnées")
        XCTAssertEqual(source?.dataSourceVariables?["SUMMARY_solution_architect"]?["fr"], "Je suis ingénieur en développement depuis plus de 15 ans.")
        XCTAssertEqual(source?.dataSourceVariables?["NAME"]?["fr"], "Foo Bar")
        XCTAssertEqual(source?.dataSourceVariables?["puce"]?["fr"], "•")
        XCTAssertEqual(source?.dataSourceVariables?["EMAIL"]?["fr"], "foo@bar.com")
        XCTAssertEqual(source?.dataSourceVariables?["PHONE"]?["fr"], "+33677889900")
        XCTAssertEqual(source?.dataSourceVariables?["GITHUB"]?["fr"], "bsbl")
        XCTAssertEqual(source?.dataSourceVariables?["LINKEDIN_ID"]?["fr"], "foo_bar")
        XCTAssertEqual(source?.dataSourceVariables?["PLACE"]?["fr"], "Annecy - France")

    }
    
    func assertStrengthsSection() {
        // fr and en
        XCTAssertEqual(2, source?.dataSourceSections?[.strengths]?.count)
        //
        let strengths = source!.dataSourceSections![.strengths]!
        XCTAssertEqual(2, strengths["fr"]!.source.count)
        XCTAssertEqual(3, strengths["en"]!.source.count)
        XCTAssertEqual("Communication", strengths["en"]!.source[0].values[0])
        XCTAssertEqual("Hands-on", strengths["en"]!.source[1].values[0])
    }
    
    func assertSections() {
        // ----------
        // sections:
        // ----------
        XCTAssertEqual(7, source?.dataSourceSections?.count)
        
    }
    
    func assertLanguageSection() {
        // ----------
        // languages:
        XCTAssertEqual(2, source?.dataSourceSections?[.languages]?.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.languages]?["fr"]?.source.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.languages]?["fr"]?.source[0].values.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.languages]?["fr"]?.source[1].values.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.languages]?["en"]?.source.count)
    }
    
    func assertEducationAndCertificationSection() {
        
        // ----------
        // education and certifications checks:
        XCTAssertEqual(2, source?.dataSourceSections?[.educationAndCertifications]?.count)
        XCTAssertEqual(3,  source?.dataSourceSections?[.educationAndCertifications]?["fr"]?.source.count)
        XCTAssertEqual(3,  source?.dataSourceSections?[.educationAndCertifications]?["en"]?.source.count)
        XCTAssertEqual(2, source?.dataSourceSections?[.certifications]?.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.certifications]?["fr"]?.source.count)
        XCTAssertEqual(2,  source?.dataSourceSections?[.certifications]?["en"]?.source.count)
        XCTAssertEqual(2, source?.dataSourceSections?[.education]?.count)
        XCTAssertEqual(1,  source?.dataSourceSections?[.education]?["fr"]?.source.count)
        XCTAssertEqual(1,  source?.dataSourceSections?[.education]?["en"]?.source.count)
        
        XCTAssertEqual(3,  source?.dataSourceSections?[.education]?["fr"]?.source[0].values.count)
        XCTAssertEqual(3,  source?.dataSourceSections?[.education]?["en"]?.source[0].values.count)
        XCTAssertEqual(3,  source?.dataSourceSections?[.certifications]?["fr"]?.source[0].values.count)
        XCTAssertEqual(3,  source?.dataSourceSections?[.certifications]?["fr"]?.source[1].values.count)
        XCTAssertEqual("Titre de mon diplôme",  source?.dataSourceSections?[.education]?["fr"]?.source[0].values[0])
        XCTAssertEqual("Mon école ou université",  source?.dataSourceSections?[.education]?["fr"]?.source[0].values[1])
        XCTAssertEqual("2005",  source?.dataSourceSections?[.education]?["fr"]?.source[0].values[2])

    }
    
    func assertExperienceSection() {
        // ----------
        // experience checks:
        XCTAssertEqual(2, source?.dataSourceSections?[.experience]?.count)

        XCTAssertEqual(2, source?.dataSourceSections?[.experience]?["fr"]?.source.count)
        XCTAssertEqual(9, source?.dataSourceSections?[.experience]?["en"]?.source[0].values.count)
        XCTAssertEqual("Technical lead", source?.dataSourceSections?[.experience]?["en"]?.source[0].values[0])
        XCTAssertEqual("Company 2 • Company sector", source?.dataSourceSections?[.experience]?["en"]?.source[0].values[1])
        XCTAssertTrue(source?.dataSourceSections?[.experience]?["en"]?.source[0].values[2].starts(with: "Nov 2018") ?? false)
        XCTAssertEqual(2, source?.dataSourceSections?[.experience]?["en"]?.source.count)
    }
    
    func assertTechnologiesSection() {
        // ----------
        // technologies checks:
        XCTAssertEqual(2, source?.dataSourceSections?[.technologies]?.count)
        guard let techs = source?.dataSourceSections?[.technologies]?["fr"] else {
            XCTFail("Missing expected list of technos")
            return
        }
        XCTAssertEqual("Lorem", techs.source[0].values[0])
    }
    
}
