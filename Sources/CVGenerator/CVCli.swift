//
//  CVCli.swift
//  CVGenerator
//
//  Created by bsbl on 07.02.20.
//

import Foundation

public class CVCli {
    
    let program: String
    let args: [String]
    
    var sourceXls: String?
    var applicationName: String?
    var templateTex: String?
    var skippedSections: [CVTemplateSection]?
    
    init(args: [String]) {
        program = String(withSubstring: args[0].split(separator: "/").last) ?? args[0]
        self.args = Array(args.suffix(from: 1))
    }
    
    func run() throws {
        try parseCLI()
        try process()
    }
    
    func process() throws {
        guard let sourceXls = sourceXls, let applicationName = applicationName, let templateTex = templateTex else {
            log("Missing required arguments: xls file, tex template or application name!", with: .error)
            throw CVError.configError
        }
        log("Loading the Excel source file...")
        let source = CVSource()
        try source.load(excelSource: sourceXls)
        log("Apply the data source to the template...")
        let fileManager = FileManager.default
        let outputFolder = fileManager.currentDirectoryPath
        
        try source.languages.forEach { lang in
            let parser = try CVTemplateParser(applicationName: applicationName, translations: source.dataSourceVariables ?? [:], skippedSections: skippedSections ?? [])
            try parser.loadTemplate(template: templateTex)
            guard let sections = source.dataSourceSections else {
                throw CVError.noDataFound("Expecting sections data")
            }
            let variables = source.standardVariables(lang: lang, applicationName: applicationName)
            parser.injectSections(sections: sections, lang: lang)
            parser.substituteVariables(variables: variables)
            log("Write the generated document: \(applicationName)_\(lang).")
            let tmpDir = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
            let tmpTex = tmpDir.appendingPathComponent("\(applicationName)_\(lang).tex")
            if fileManager.fileExists(atPath: tmpTex.absoluteString) {
                try? fileManager.removeItem(at: tmpTex)
            }
            try parser.resumeContent?.joined(separator: "\n").write(to: tmpTex, atomically: false, encoding: .utf8)
            log("Temporary file created: tmpTex=\(tmpTex)")
            let pdfCreation = CVLatexPdf().buildPdf(texFile: tmpTex, outputPdfDir: outputFolder)
            if pdfCreation.exit != 0 {
                throw CVError.dataError("PDF creation failed: \(pdfCreation.exit):\n\(pdfCreation.output)")
            }
            else {
                log("Output file generated in: \(outputFolder)")
            }
        }
    }
    
    func parseCLI() throws {
        log("Parsing command line...")
        guard !args.isEmpty && !(args[0].contains("-h")) else {
            log("""
                Usage: \(program) --tex=<Latex template to be used> --xls=<path to the Excel xslx file containing the resume content> --application=<name of the application used to generate the outputs> [options]
                Options:
                - skipped-sections=s1,s2: list of sections (s1 and s2 in the example) to be skipped. Sections are: Experience,Strengths,Education,Certifications,Languages,Technologies
                """)
            return
        }
        //log("switch command line from: \(args)")
        try args.forEach { (arg) in
            let decomposed = arg.split(separator: "=")
            switch decomposed[0] {
            case "--tex" where decomposed.count == 2:
                self.templateTex = String(decomposed[1])
            case "--xls" where decomposed.count == 2:
                self.sourceXls = String(decomposed[1])
            case "--application" where decomposed.count == 2:
                applicationName = String(decomposed[1])
            case "--skipped-sections" where decomposed.count == 2:
                skippedSections = decomposed[1].split(separator: ",").compactMap {
                    CVTemplateSection(rawValue: String($0)) }
                log("Sections to be skipped: \(skippedSections ?? [])")
            default:
                log("Invalid command: \(arg)", with: .error)
                throw CVError.configError
            }
        }
    }
    
}
