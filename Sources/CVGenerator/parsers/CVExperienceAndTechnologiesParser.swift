//
//  CVExperienceAndTechnologiesParser.swift
//  CVExperienceAndTechnologiesParser
//
//  Created by bsbl on 19.02.20.
//

import Foundation
import CoreXLSX

///
/// Structure of the experience sheet:
/// period_<lang>    company_<lang>    location_<lang>   companyDesc_<lang>   experience_<lang>    details_<lang>     technologies
/// ...
class CVExperienceAndTechnologiesParser: CVSectionSourceParser {

    var sourceType: CVSourceType = .experience
    
    var itemIdSequence = 0
    
    func isApplicable(for worksheet: CVExcelWorksheet) -> Bool {
        return worksheet.headers.map { header -> String in
            let tokens = header.split(separator: "_")
            guard let key = tokens[safe: 0] else { return "" }
            return String(key)
            }
        .filter { $0.compare("company", options: .caseInsensitive) == .orderedSame }
        .count > 0
    }
    
    enum ExperiencePropertyType {
        case period
        case company
        case companyDesc
        case experience
        case location
        case details
        case technos
        case from
        case to
    }
    struct ExperienceProperty {
        let type: ExperiencePropertyType
        let lang: String?
        
        static func parse(val: String) ->  ExperienceProperty? {
            let vals = val.split(separator: "_")
            let lang = vals.count > 1 ? String(vals[1]) : nil
            switch vals[0].lowercased() {
            case "from":
                return ExperienceProperty(type: .from, lang: lang)
            case "to":
                return ExperienceProperty(type: .to, lang: lang)
            case "company":
                return ExperienceProperty(type: .company, lang: lang)
            case "companydesc":
                return ExperienceProperty(type: .companyDesc, lang: lang)
            case "experience":
                return ExperienceProperty(type: .experience, lang: lang)
            case "location":
                return ExperienceProperty(type: .location, lang: lang)
            case "details":
                return ExperienceProperty(type: .details, lang: lang)
            case "technologies":
                return ExperienceProperty(type: .technos, lang: lang)
            default:
                return nil
            }
        }
    }
    
    func parseSheetContent(worksheet: CVExcelWorksheet) throws -> (sections: [CVTemplateSection:[String:CVSourceSection]], variables: [String:[String:String]]) {
        // extract langs and property type/language per column index:
        var columnsIndices: [ExperienceProperty?] = []
        var langs = Set<String>()
        for (_,cell) in worksheet.headers.enumerated() {
            if let type = ExperienceProperty.parse(val: cell) {
                columnsIndices.append(type)
                if let lang = type.lang {
                    langs.insert(lang)
                }
            }
        }
        // create section container for each section and language:
        let initialData:[String:CVSourceSection] = langs.reduce([:]) { res,lang in
            var res = res
            res[lang] = CVSourceSection(section: .experience)
            return res
        }
        // dates are mandatory except for the last experience where
        // the 'to' date is not defined since the period is opened
        // in this case the unset date is replaced by the current
        // date
        var isLastExperienceMet = false
        // loop thru the rows
        var previousRow = worksheet.headers.map{_ in ""}
        let result = try worksheet.data().reduce(initialData) { (section,row) -> [String:CVSourceSection] in
            itemIdSequence+=1
            let section = section
            // create one item per language
            let langSectionItem = langs.reduce([:]) { res,lang -> [String:CVSourceSectionItem] in
                    var res = res
                    res[lang] = addAndGet(id: "\(itemIdSequence)", langSection: section, lang: lang)
                    return res
            }
            // loop thru the cells of the row and fill sections:
            var from: String?
            var to: String?
            for (index,cell) in row.enumerated() {
                var theLang: String? = nil
                var position: Int? = nil
                
                if let columnPropertyType = columnsIndices[index] {
                    theLang = columnPropertyType.lang
                    switch columnPropertyType.type {
                    case .experience:
                        position = 0
                    case .company:
                        position = 1
                    case .location:
                        position = 3
                    case .details:
                        position = 4
                    case .technos:
                        position = 5
                    case .companyDesc:
                        position = 6
                    case .from:
                        from = cell
                        position = 7
                    case .to:
                        to = cell
                        position = 8
                    default:
                        position = nil
                    }
                }
                if let pos = position {
                    if pos > 6, let from_ = from, let to_ = to {
                        // period has to be computed
                        try langs.forEach {
                            // parse date from data source
                            let fromMmmYyyy = try! TechnologiesUtils.extractMonthAndYear(monthYearText: from_, throwErrorIfEmpty: true)
                            let toMmmYyyy = try TechnologiesUtils.extractMonthAndYear(monthYearText: to_, throwErrorIfEmpty: isLastExperienceMet)
                            
                            // build the period expression and register it into the section
                            langSectionItem[$0]?.addValue(pos: 2,
                                value: try TechnologiesUtils.buildPeriodExpression(
                                    lang: $0, fromMonth: fromMmmYyyy!.month, fromYear: fromMmmYyyy!.year,
                                    toMonth: toMmmYyyy?.month, toYear: toMmmYyyy?.year)
                            )
                            // register the from/to expressions individually
                            langSectionItem[$0]?.addValue(pos: 7, value: "\(fromMmmYyyy!.month)/\(fromMmmYyyy!.year)")
                            if toMmmYyyy?.month == nil || toMmmYyyy?.year == nil {
                                langSectionItem[$0]?.addValue(pos: 8, value: "")
                            }
                            else {
                                langSectionItem[$0]?.addValue(pos: 8, value: "\(toMmmYyyy!.month)/\(toMmmYyyy!.year)")
                            }
                        }
                    }
                    else {
                        let val: String = {
                            if cell.isEmpty { return previousRow[index] }
                            else {
                                let tmp = position == 4 ? CVDataNormalizer.addBullets(cell) : cell
                                previousRow[index] = tmp
                                return tmp
                            }
                        }()
                        if let lang = theLang { langSectionItem[lang]?.addValue(pos: pos, value: val) }
                        else { langs.forEach {  langSectionItem[$0]?.addValue(pos: pos, value: val)} }
                    }
                }
            }
            isLastExperienceMet = true
            return section
        }
        // build technologies section
        return (sections: [.experience: result, .technologies: try buildTechSection(result)], variables: [:])
    }
    
    private func addAndGet(id: String, langSection: [String:CVSourceSection], lang: String) -> CVSourceSectionItem {
        let sectionItem = CVSourceSectionItem(id: id, prefix: "\\experience", expectedValuesCount: 9)
        langSection[lang]?.addSectionItem(item: sectionItem)
        return sectionItem
    }
    
    private func buildTechSection(_ langExperiences: [String:CVSourceSection]) throws -> [String:CVSourceSection] {
        // create the map of lang -> technos section
        let techSections: [String:CVSourceSection] = langExperiences.keys.reduce([:]) {
            var map = $0
            map[$1] = CVSourceSection(section: .technologies)
            return map
        }
        // go through each experiences
        return try langExperiences.reduce(techSections) { res,expSection -> [String:CVSourceSection] in
            // the language
            let lang = expSection.key
            // get the techno section corresponding to the lang
            guard let section = res[lang] else { return res }
            // for each experience details
            let technos: [ExperiencePeriod] = try expSection.value.source.map { techs in
                // extract the list of techs used
                let listOfTechs = TechnologiesUtils.normalizeRawTechnos(techs.values[5])
                // parse the dates from the period text
                let fromDate = try TechnologiesUtils.monthYearToDate(techs.values[7], type: .from)
                let toDate = try TechnologiesUtils.monthYearToDate(techs.values[8], type: .to)
                //
                return ExperiencePeriod(from: fromDate, to: toDate, technos: listOfTechs)
            }
            var id = 1
            ExperiencesPeriods(periods: technos)
                .orderedTechnos().forEach {
                    let item = CVSourceSectionItem(id: "\(id)", prefix: "", expectedValuesCount: 1, isWrappedInCurlyBraces: false)
                    item.addValue(pos: 0, value: $0)
                    section.addSectionItem(item:  item)
                    id = id + 1
            }
            return res
        }
    }

    
    // technologies:
    // - most recent (deltaT)
    // - how long it was used (duration)
    // - ordering in the list ()
    // now() is jan. 2020
    // 1. nov. 2018: java, springboot, tomcat, git [13 months]
    // 2. dec. 2016 nov. 2018: iOS, Swift, java, springboot, git [23 months]
    // 3. sep. 2014 dec. 2016: java, springboot, tomcat, git [26 months]
    //
    // 1 only: java:4, springboot:3, tomcat:2, git:1
    // -> (java:4, springboot:3, tomcat:2, git:1)
    // 2 only: java: 4x1x13, springboot:3x1x13, tomcat:2x1x13, git:1x1x13
    //       + iOS:5x0.5x23, Swift4x0.5x23, java3x0.5x23, springboot2x0.5x23, git1X0.5x23
    //       -> (java)
    
}
