//
//  CVCerticateParser.swift
//  CVProfileParser
//
//  Created by bsbl on 13.02.20.
//

import Foundation
import CoreXLSX

///
/// Structure of the certiticates sheet:
/// certificate_type  |  certificate_desc          |                               fr                          |                          en
/// --------------------- +------------------------------+------------------------------------------------+-------------------------------------------------
/// education           |   1_name                     | Master en génie logiciel                    | Master Degree in Computing
///             |   1_deliveredBy           | Université de Tartenpion                   | University of Tartenpion
///             |   1_deliveryDate         | 2007                                                  | 2007
/// certification         |   2_name                    | Machine Learning                             |  Machine Learning
///             |   2_deliveredBy          | Coursera - Université d'Onolila         | Coursera - Onolila University
/// ............
class CVCerticateParser: CVSectionSourceParser {

    var sourceType: CVSourceType = .educationAndCertifications
    
    func isApplicable(for worksheet: CVExcelWorksheet) -> Bool {
        return (worksheet.headers[safe: 0]?.compare("certificate_type", options: .caseInsensitive) ?? .orderedAscending ) == .orderedSame
    }
    
    enum CertificateType: String {
        case education = "education"
        case certification = "certification"
        func prefix() -> String {
            switch self {
            case .education:
                return "certificate"
            default:
                return "certification"
            }
        }
    }
    
    enum CertificatePropertyType {
        case name(String)
        case deliveredBy(String)
        case deliveryYear(String)
        
        static func parse(val: String) ->  CertificatePropertyType? {
            let vals = val.split(separator: "_")
            if vals.count < 2 { return nil }
            let id = String(vals[0])
            switch vals[1].lowercased() {
            case "name":
                return .name(id)
            case "deliveredby":
                return .deliveredBy(id)
            case "deliveryyear":
                return .deliveryYear(id)
            default:
                return nil
            }
        }
    }

    
    func parseSheetContent(worksheet: CVExcelWorksheet) -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) {
        // first row: give the languages (column 1...)
        let langs = Array(worksheet.headers.dropFirst(2))
        // create section container for each section and language:
        let initialSections = createInitialSections(langs: langs)
        // loop thru the rows
        var lastCertificateType: CertificateType = .certification
        let result = worksheet.data().reduce(initialSections) { (sections,row) -> [CVTemplateSection:[String:CVSourceSection]] in
            guard let certificatePropertyTypeCell = row[safe: 1], let certificatePropertyType = CertificatePropertyType.parse(val: certificatePropertyTypeCell) else {
                return sections
            }
            // not need to determine the certificate type on every row:
            let certificateTypeCell = row[safe: 0]
            guard let certificateType = certificateTypeCell?.isEmpty ?? true ?
                            lastCertificateType :
                            CertificateType(rawValue: certificateTypeCell!.lowercased()) else {
                return sections
            }
            let sections = sections
            // it is possible to mix education and certifications or to separate them
            // from parsing standpoint, create the 3 sections, the template will define
            // which one to be applied
            let sectionsToBeFilled: [CVTemplateSection] = certificateType == .certification
                ? [.certifications, .educationAndCertifications]
                : [.education, .educationAndCertifications]
            // loop thru the cells of the row and fill sections:
            parseRows(row: row, langs: langs, sectionsToBeFilled: sectionsToBeFilled, sections: sections, certificateType: certificateType, certificatePropertyType: certificatePropertyType)
            // keep the last certificateType since it might be not repeated
            // in every row for consecutive rows related to the same id
            lastCertificateType = certificateType
            return sections
        }
        return (sections: result, variables: [:])
    }
    
    private func parseRows(row: [String], langs: [String], sectionsToBeFilled: [CVTemplateSection], sections: [CVTemplateSection : [String : CVSourceSection]], certificateType: CertificateType, certificatePropertyType: CertificatePropertyType) {
        for (index,cell) in row.dropFirst(2).enumerated() {
            if let lang = langs[safe: index] {
                
                var sectionItem: CVSourceSectionItem? = nil
                
                sectionsToBeFilled.forEach { sectionToBeFilled in
                    if let section = sections[sectionToBeFilled] {
                            var position: Int
                            switch certificatePropertyType {
                            case .name(let id):
                                sectionItem = getOrAddAndGet(section: section[lang]!, id: id, prefix: certificateType.prefix())
                                position = 0
                            case .deliveredBy(let id):
                                sectionItem = getOrAddAndGet(section: section[lang]!, id: id, prefix: certificateType.prefix())
                                position = 1
                            case .deliveryYear(let id):
                                sectionItem = getOrAddAndGet(section: section[lang]!, id: id, prefix: certificateType.prefix())
                                position = 2
                            }
                            sectionItem!.addValue(pos: position, value: cell)
                        
                    }
                    else {
                        print("no data found for the specified section: \(sectionToBeFilled)")
                    }
                }
            }
        }

    }
    
    private func getOrAddAndGet(section: CVSourceSection, id: String, prefix: String) -> CVSourceSectionItem {
        if let sectionItem = section.source.filter({ id == $0.id }).first {
            return sectionItem
        }
        else {
            let sectionItem = CVSourceSectionItem(id: id, prefix: "\\\(prefix)", expectedValuesCount: 3)
            section.addSectionItem(item: sectionItem)
            return sectionItem
        }
    }
    
    private func createInitialSections(langs: [String]) -> [CVTemplateSection:[String:CVSourceSection]] {
        let initialSections:[CVTemplateSection:[String:CVSourceSection]] = [
            .educationAndCertifications: langs.reduce([:]) { res,lang in
                var res = res
                res[lang] = CVSourceSection(section: .educationAndCertifications)
                return res
            },
            .education: langs.reduce([:]) { res,lang in
                var res = res
                res[lang] = CVSourceSection(section: .education)
                return res
            },
            .certifications: langs.reduce([:]) { res,lang in
                var res = res
                res[lang] = CVSourceSection(section: .certifications)
                return res
            }
        ]
        return initialSections
    }
}
