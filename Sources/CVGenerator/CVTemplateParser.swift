//
//  CVTemplateParser.swift
//  CVGenerator
//
//  Created by bsbl on 08.02.20.
//

import Foundation

/**
 * Steps are:
 * - load the template latex file
 * - substitute the variables occurences
 * - build sections which:
 *    - for each line extract the sections
 *    - find the corresponding data set from `[CVSourceSection]`
 *    - if no data then keep the section as is
 *    - if data found insert into the line the content of the section from the CVSourceSection
 */
protocol CVTemplateParserProtocol {
    /// Provide a getter on the content of the resume.
    var resumeContent: [String]? {get}
    /**
     * Load the template from the file system into memory.
     */
    func loadTemplate(template: String) throws
    /**
     * Substitute variables (such as <NAME>) with real
     * values read from the data source.
     */
    func substituteVariables(variables: [CVTemplateVariable:String])
    /**
     * Inject sections into the document.
     */
    func injectSections(sections: [CVTemplateSection:[String:CVSourceSection]], lang: String)
    /**
     * For each section, the list of items to be added into it.
     */
    func buildSections(sections: [CVTemplateSection:CVSourceSection])
    /**
     * Extract the section(s) from a text.
     * `start` provides the position of the first character in the text
     * `end` provides the position of the closing '}' (end of the
     * section name).
     * This is used further to insert the section content in place.
     */
    func extractSections(text: String) -> [CVTemplateSection: (start:Int, end:Int)]
    
}


class CVTemplateParser: CVTemplateParserProtocol {
    /// Current start of the resume content
    /// Starts by the template itself and evolves as
    /// the process of templat's population progresses
    var resumeContent: [String]?

    let regexp: NSRegularExpression
    
    /// Translations (e.g. section names) - en -> [k,v], fr -> [k,v] ...
    let translations: [String: [String:String]]
    
    let applicationName: String
    
    var skippedSections: [CVTemplateSection]
    
    init(applicationName: String, translations: [String:[String:String]], skippedSections: [CVTemplateSection]) throws {
        self.translations = translations
        self.applicationName = applicationName
        self.skippedSections = skippedSections
        regexp = try NSRegularExpression(pattern: "\\\\section\\{([^}]+)\\}")
    }
    
    func extractSections(text: String) -> [CVTemplateSection: (start:Int, end:Int)] {
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regexp.matches(in: text, range: range)
        return matches.reduce([:]) { (acc:[CVTemplateSection: (start:Int, end:Int)], match:NSTextCheckingResult) -> [CVTemplateSection: (start:Int, end:Int)] in
            let range = NSMakeRange(match.range.lowerBound+9, match.range.length-10)
            let s = String(text[Range(range, in: text)!])
            guard let section = CVTemplateSection(rawValue: s) else {
                return acc
            }
            var acc = acc
            acc[section] = (start: match.range.lowerBound, end:match.range.upperBound)
            return acc
        }
    }
    
    func loadTemplate(template: String) throws {
        log("Load template from: \(template)")
        let file = FileManager()
        guard let data = file.contents(atPath: template) else {
            throw CVError.fileNotFound(template)
        }
        guard let content = String(data: data, encoding: .utf8) else {
            throw CVError.noDataFound(template)
        }
        let lines = content.components(separatedBy: "\n")
        self.resumeContent = lines
    }
    
    func substituteVariables(variables: [CVTemplateVariable:String]) {
        guard let templateLines = resumeContent else { return }
        let newTemplateLines:[String] = templateLines.reduce([]) { list,val in
            var list = list
            let newValue = variables.reduce(val) { line,variable in
                return line.replacingOccurrences(of: "<\(variable.key.rawValue)>", with: variable.value)
            }
            list.append(newValue)
            return list
        }
        self.resumeContent = newTemplateLines
    }
    
    func injectSections(sections: [CVTemplateSection:[String:CVSourceSection]], lang: String) {
        let langSections: [CVTemplateSection:CVSourceSection] = sections.reduce([:]) { res,map in
            guard let langVal = map.value[lang] else { return res }
            var res = res
            res[map.key] = langVal
            return res
        }
        buildSections(sections: langSections)
    }
    
    func buildSections(sections: [CVTemplateSection:CVSourceSection]) {
        guard let templateLines = resumeContent else { return }
        //let sourceSectionsList = sections.map { $0.section }
        let newTemplateLines:[String] = templateLines.reduce([]) { list,line in
            var list = list
            // check whether the line has section info:
            let lineSections = extractSections(text: line)
            if lineSections.isEmpty {
                list.append(line)
            }
            else {
                // Need now to inject its content within the line.
                // Then for each detected line section starting by
                // the end (to keep the start/end position valid
                // for the current section):
                let newLine = lineSections.reversed().reduce(line) { res,lineSection in
                    // if the source section has data for this section:
                    guard let source = sections[lineSection.key] else { return res }
                    /// TODO translation for sections
                    /*guard let section = sections.first(where: {$0.section == lineSection.key}) else {
                        res.append(lineSection.key)
                        return res
                    }*/
                    // ok now fill the section:
                    if skippedSections.contains(source.section) {
                        log("Section is skipped: \(source.section)", with: .warn)
                        return res
                    }
                    return insertSectionContentIntoLine(line, source, lineSection)
                }
                list.append(newLine)
            }
            return list
        }
        self.resumeContent = newTemplateLines
    }
    
    /// Generate the section items string and insert it into the line of the document
    func insertSectionContentIntoLine(_ line: String, _ section: CVSourceSection, _ lineSection: (key: CVTemplateSection, value: (start: Int, end: Int))) -> String {
        let sectionContent = section.source.map { $0.build() }.joined(separator: lineSection.key.separator())
        let i = line.index(line.startIndex, offsetBy: lineSection.value.end)
        return "\(line.prefix(lineSection.value.end))\n\(sectionContent)\n\(line.suffix(from: i))"
    }
    
}
