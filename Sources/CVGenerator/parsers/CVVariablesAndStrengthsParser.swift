//
//  CVVariablesAndStrengthsParser.swift
//  CVProfileParser
//
//  Created by bsbl on 13.02.20.
//

import Foundation
import CoreXLSX

///
/// Structure of the variables sheet - strengths are a just a variable
/// variable                               |           fr                       |           en                | description
/// ------------------------------------+-----------------------------+-------------------------+-----------------------------------------
/// section_strength                  | Forces                        |  Strengths              | section title
/// coordonnees                       |  Coordonnées             |  Contact Details     | single valued variable
/// profile_solution_architect   |  Architecte de solution | Solution architect   | variable prefixed by the application name (command line option). This allows to have different values based on this. Fallback on non prefixed values or not found.
/// strengths_items_solution_architect | A\nB\C           | A\B\C                      | list of strength items per language and application name
///
class CVVariablesAndStrengthsParser: CVSectionSourceParser {

    var sourceType: CVSourceType = .variables
    
    var identifier: Int = 0
    
    func isApplicable(for worksheet: CVExcelWorksheet) -> Bool {
        return (worksheet.headers[safe: 0]?.compare("variable", options: .caseInsensitive) ?? .orderedAscending ) == .orderedSame
    }
    
    func parseSheetContent(worksheet: CVExcelWorksheet) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) {
        // first row: give the languages
        let langs = Array(worksheet.headers.dropFirst())
        let initialSections: [CVTemplateSection:[String:CVSourceSection]] = [
            .strengths: langs.reduce([:]) { res,lang in
                var res = res
                res[lang] = CVSourceSection(section: .strengths)
                return res
            }
        ]
        let result = worksheet.data().reduce((sections: initialSections, variables: [:])) { (map,row) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) in
            var (sections, variables) = map
            guard let varName = row[safe: 0], var strengthsSection = sections[.strengths] else {
                return map
            }
            if varName.hasPrefix("strengths_items") {
                // strength section:
                addStrength(langSection: &strengthsSection, langs: langs, varName: varName, rowMinusFirstCell: Array(row.dropFirst()))
            }
            else {
                var varValues: [String:String] = [:]
                for (index,cell) in row.dropFirst().enumerated() {
                    if let lang = langs[safe: index] {
                        varValues[lang] = cell
                    }
                }
                variables[varName] = varValues
            }
            return (sections: sections, variables: variables)
        }
        return result
    }
    
    func addStrength(langSection: inout [String:CVSourceSection], langs: [String], varName: String, rowMinusFirstCell: [String]) {
        for (index,cell) in rowMinusFirstCell.enumerated() {
            if let lang = langs[safe: index] {
                cell.split(separator: "\n")
                    .map { String($0) }
                    .forEach {
                        identifier = identifier+1
                        langSection[lang]?.addSectionItem(item: CVSourceSectionItem(id: "\\identifier", prefix: "\\strength", values: [$0]))
                }
            }
        }
    }
    
}
