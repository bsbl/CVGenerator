//
//  CVSource.swift
//  CVGenerator
//
//  Created by bsbl on 09.02.20.
//
import CoreXLSX


// ------------------------------------------------------------
protocol CVSourceProtocol {
    
    /// Per source type -> per language (en,fr..) -> the section data
    var dataSourceSections: [CVTemplateSection:[String:CVSourceSection]]? {get}
    
    /// per variable -> per language -> the variable value
    var dataSourceVariables: [String:[String:String]]? {get}
    
    /// per language -> standard variables -> value
    func standardVariables(lang: String, applicationName: String?) -> [CVTemplateVariable:String]
    /**
     * Load the data source to apply the template on
     * The structure of the data source is explained in the project's readme.
     */
    func load(excelSource: String) throws
    
    var languages: Set<String> {get}
}

// ------------------------------------------------------------
/// Mapped to a sheet name in the spreadsheet
enum CVSourceType: String {
    case variables = "Variables"
    case experience = "Experience"
    case educationAndCertifications = "Education \\& Certifications"
    case languages = "Languages"
}

// ------------------------------------------------------------
protocol CVSectionSourceParser {
    
    var sourceType: CVSourceType {get}
    
    /**
     * Determine whether the structure of the worksheet can
     * be parsed by the parser.
     */
    func isApplicable(for worksheet: CVExcelWorksheet) -> Bool
    
    /**
     * Parser specific to a given `CVTemplateSection`
     * It load the data from a sheet and returns per language,
     * the source sections.
     */
    func parseSheetContent(worksheet: CVExcelWorksheet) throws -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]])
    
}

// ------------------------------------------------------------
class CVSource: CVSourceProtocol {
    
    var dataSourceSections: [CVTemplateSection:[String:CVSourceSection]]?
    
    var dataSourceVariables: [String:[String:String]]?
    
    var languages: Set<String> {
        return Set(dataSourceSections!.values.flatMap { $0.keys })
    }
    
    func standardVariables(lang: String, applicationName: String?) -> [CVTemplateVariable:String] {
        guard let sourceVars = dataSourceVariables else { return [:] }
        return sourceVars.reduce([:]) {res,val in
            guard let varType = CVTemplateVariable.parse(variableName: val.key, applicationName: applicationName) else {
                return res
            }
            var res = res
            res[varType] = val.value[lang]! // we want the app to crash here if the specfied lang does not exist
            return res
        }
    }
    
    /// List of available sheet parsers
    var sectionSourceParsers: [CVSourceType:CVSectionSourceParser] = [
        .variables:CVVariablesAndStrengthsParser(),
        .educationAndCertifications:CVCerticateParser(),
        .languages: CVLanguageParser(),
        .experience: CVExperienceAndTechnologiesParser()
    ]
    
    func load(excelSource: String) throws {
        // see https://github.com/MaxDesiatov/CoreXLSX
        guard let file = XLSXFile(filepath: excelSource), let sharedStrings = try?  file.parseSharedStrings() else {
            fatalError("XLSX file \(excelSource) corrupted or does not exist")
        }
        // loop through the worksheets:
        let parsedSectionsAndVariables = try file.parseWorksheetPaths().reduce((sections: [:], variables: [:])) { (map,path) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) in
            log("Source: sheet \(path) found in the Excel source file")
            let ws = try file.parseWorksheet(at: path)
            guard let sectionsAndVars = loadWorksheet(name: path, worksheet: ws, sharedStrings: sharedStrings) else {
                // simply ignore the worksheet as it's not mapped to any section
                return map
            }
            var (sections, variables) = map
            sectionsAndVars.sections.forEach { entry in
                sections[entry.key] = entry.value
            }
            sectionsAndVars.variables.forEach { item in
                variables[item.key] = item.value
            }
            return (sections: sections, variables: variables)
        }
        self.dataSourceSections = parsedSectionsAndVariables.sections
        self.dataSourceVariables = parsedSectionsAndVariables.variables
    }
    
    func loadWorksheet(name path: String, worksheet: Worksheet, sharedStrings: SharedStrings) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]])? {
        let cvWorksheet = CVExcelWorksheet(worksheet: worksheet, sharedStrings: sharedStrings)
        guard let parser = sectionSourceParsers.filter({ $0.value.isApplicable(for:
                cvWorksheet
            )}).first else {
            log("No parser found for the current worksheet: name=\(path)")
            return nil
        }
        do {
            return try parser.value.parseSheetContent(worksheet: cvWorksheet)
        }
        catch {
            log("Unexpected exception: \(error)!")
            return nil
        }
    }
    
    
}
