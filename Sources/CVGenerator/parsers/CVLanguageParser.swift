//
//  CVLanguageParser.swift
//  CVLanguageParser
//
//  Created by bsbl on 17.02.20.
//

import Foundation
import CoreXLSX

///
/// Structure of the language sheet:
/// lang                                    |                          fr                        |                           en
/// -----------------------------------+-------------------------------------------+-------------------------------------------------
/// en_name                            | Anglais                                        | English
/// en_level                             | Lu, écrit, parlé                             |  Fluent
/// fr_name                             | Français                                      |  French
/// fr_level                              | Maternelle                                    |  Native
/// ...
class CVLanguageParser: CVSectionSourceParser {

    var sourceType: CVSourceType = .educationAndCertifications
    
    func isApplicable(for worksheet: CVExcelWorksheet) -> Bool {
        return (worksheet.headers[safe: 0]?.compare("lang", options: .caseInsensitive) ?? .orderedAscending ) == .orderedSame
    }
    
    enum LanguagePropertyType {
        case name(String)
        case level(String)
        
        static func parse(val: String) ->  LanguagePropertyType? {
            let vals = val.split(separator: "_")
            if vals.count < 2 { return nil }
            let id = String(vals[0])
            switch vals[1].lowercased() {
            case "name":
                return .name(id)
            case "level":
                return .level(id)
            default:
                return nil
            }
        }
    }
    
    func parseSheetContent(worksheet: CVExcelWorksheet) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) {
        // first row: give the languages (column 1...)
        let langs = Array(worksheet.headers.dropFirst())
        // create section container for each section and language:
        let initialData:[String:CVSourceSection] = langs.reduce([:]) { res,lang in
            var res = res
            res[lang] = CVSourceSection(section: .languages)
            return res
        }
        // loop thru the rows
        let result = worksheet.data().reduce(initialData) { (section,row) -> [String:CVSourceSection] in
            guard let languagePropertyTypeCell = row[safe: 0], let languagePropType = LanguagePropertyType.parse(val: languagePropertyTypeCell) else {
                return section
            }
            let section = section
            // loop thru the cells of the row and fill sections:
            for (index,cell) in row.dropFirst().enumerated() {
                if let lang = langs[safe: index] {
                    var sectionItem: CVSourceSectionItem
                    var position: Int
                    switch languagePropType {
                    case .name(let id):
                        sectionItem = getOrAddAndGet(section: section[lang]!, id: id)
                        position = 0
                    case .level(let id):
                        sectionItem = getOrAddAndGet(section: section[lang]!, id: id)
                        position = 1
                    }
                    sectionItem.addValue(pos: position, value: cell)
                }
            }
            return section
        }
        return (sections: [.languages: result], variables: [:])
    }
    
    private func getOrAddAndGet(section: CVSourceSection, id: String) -> CVSourceSectionItem {
        if let tmp = section.source.filter({ id == $0.id }).first {
            return tmp
        }
        else {
            let sectionItem = CVSourceSectionItem(id: id, prefix: "\\langLevel", expectedValuesCount: 2)
            section.addSectionItem(item: sectionItem)
            return sectionItem
        }
    }
}
