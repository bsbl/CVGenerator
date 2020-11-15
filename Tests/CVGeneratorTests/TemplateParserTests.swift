//
//  TemplateParserTests.swift
//  CVGenerator
//
//  Created by bsbl on 09.02.20.
//

import XCTest

class TemplateParserTests: XCTestCase {

    var parser: CVTemplateParser?
    
    override func setUp() {
        do {
            let parser = try CVTemplateParser(applicationName: "solution_architect", translations: [
                "fr":[
                    "Strengths": "Points forts",
                    "Education \\& Certifications": "Formations",
                    "Languages": "Langues",
                    "Experience": "Expérience Professionnelle"
                ]
            ], skippedSections: [])
            self.parser = parser
            try parser.loadTemplate(template: "/Users/sbl/Documents/Latex/resume-genetator/CVGenerator/Tests/CVGeneratorTests/template.tex")
        } catch {
            print("Test failed with error: \(error).")
            XCTFail()
        }
    }
    
    func testLoadTemplate() {
        XCTAssertEqual(230, parser?.resumeContent?.count ?? -1)
        XCTAssertEqual("% ------------------------------------------------------", parser?.resumeContent?[0] ?? "")
    }
    
    func testSubstituteVariables() {
        //line 117: \cfoot{\color{gray66} \faEnvelope \ <EMAIL> |  \faPhoneSquare \ <PHONE> | \faMapMarker \ <PLACE>}
        //line 175: \begin{center}{\Huge \color{MidnightBlue}<NAME>}\end{center}
        //line 177: \begin{center}{\huge \color{gray66}<JOBTITLE>}\end{center}
        //line 183: \faEnvelope \ \href{mailto:<EMAIL>}{<EMAIL>} | \faPhoneSquare \ \href{tel:<PHONE>}{<PHONE>} | \faLinkedinSquare \ \href{https://www.linkedin.com/in/<LINKEDIN_ID>/}{<NAME>} \faGithub \ \href{https://github.com/<GITHUB>/}{<GITHUB>}
        //line 188: {\color{gray33}\noindent{<SUMMARY>}}
        let vars: [CVTemplateVariable:String] = [
            .name:"Foo Bar",
            .jobTitle:"Software Engineer",
            .jobSummary:"I have 15+ years of software engineering background in different area such as mobile, Web and backend.",
            .email:"toto@thetotocorp.com",
            .phone:"+33644556677",
            .linkedIn:"Toto",
            .github:"toto",
            .place:"Geneva - Switzerland"
        ]
        parser?.substituteVariables(variables: vars)
        guard let templateLines = parser?.resumeContent else {
            XCTFail("No line found in the Latex template")
            return
        }
        XCTAssertEqual("\\cfoot{\\color{gray66} \\faEnvelope \\ toto@thetotocorp.com |  \\faPhoneSquare \\ +33644556677 | \\faMapMarker \\ Geneva - Switzerland}", templateLines[122])
        XCTAssertEqual("  \\begin{center}{\\Huge \\color{MidnightBlue}Foo Bar}\\end{center}", templateLines[180])
        XCTAssertEqual("  \\begin{center}{\\huge \\color{gray66}Software Engineer}\\end{center}", templateLines[182])
        XCTAssertEqual("  \\faEnvelope \\ \\href{mailto:toto@thetotocorp.com}{toto@thetotocorp.com} | \\faPhoneSquare \\ \\href{tel:+33644556677}{+33644556677} | \\faLinkedinSquare \\ \\href{https://www.linkedin.com/in/Toto/}{Foo Bar} \\faGithub \\ \\href{https://github.com/toto/}{toto}", templateLines[188])
        XCTAssertEqual("  {\\color{gray33}\\noindent{I have 15+ years of software engineering background in different area such as mobile, Web and backend.}}", templateLines[193])
    }
    
    func testSectionsDetection() {
        //pitfall:
        //line 62-63:
        // \titleformat
        // {\section} % command

        //correct:
        //200: \section{Strengths}
        //202: \section{Education \& Certifications}
        //204: \section{Languages}
        //206: \section{Technologies}
        //215: \section{Experience}
        let tests: [CVTemplateSection:Int] = [
            .strengths:205,
            .educationAndCertifications:207,
            .languages:209,
            .technologies:211,
            .experience:220,
        ]
        tests.forEach { test in
            let line = parser!.resumeContent![test.value]
            let res = parser?.extractSections(text: line)
            XCTAssertEqual(1, res!.count)
            XCTAssertEqual(test.key, res!.first!.key)
            XCTAssertEqual(line.count, res!.first!.value.end)
        }
        
        // test corner cases:
        let text = "\\section{Strengths}blah\\section{Education \\& Certifications}\\section{Languages}"
        let res = parser?.extractSections(text: text)
        XCTAssertEqual(3, res!.count)
        XCTAssertEqual(0, res![.strengths]!.start)
        XCTAssertEqual(19, res![.strengths]!.end)
        XCTAssertEqual(23, res![.educationAndCertifications]!.start)
        XCTAssertEqual(60, res![.educationAndCertifications]!.end)
        XCTAssertEqual(text.count-19, res![.languages]!.start)
        XCTAssertEqual(text.count, res![.languages]!.end)
    }
    
    func testInsertSection() {
        let items = [
            CVSourceSectionItem(
                id: "1",
                prefix:"\\strength",
                values: ["Strength1"]
            ),
            CVSourceSectionItem(
                id: "2",
                prefix:"\\strength",
                values: ["Strength2"]
            ),
            CVSourceSectionItem(
                id: "3",
                prefix:"\\strength",
                values: ["Strength3"]
            )
        ]
        let section = CVSourceSection(
            section: CVTemplateSection.strengths,
            source: items
        )
        let result = self.parser!.insertSectionContentIntoLine( "\\section{Strengths}blah\\section{Education \\& Certifications}\\section{Languages}", section, (key: CVTemplateSection.strengths, value: (start: 0, end: 19)))
        
        XCTAssertEqual("\\section{Strengths}\n\\strength{Strength1}\n\\strength{Strength2}\n\\strength{Strength3}\nblah\\section{Education \\& Certifications}\\section{Languages}", result)

    }
    
}
