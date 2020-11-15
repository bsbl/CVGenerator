//
//  CVTemplateVarConfig.swift
//  CVGenerator
//
//  Created by bsbl on 08.02.20.
//

import Foundation

/// variables present in the document inside <> marks.
/// e.g. <NAME> stands for the name of the candidate
enum CVTemplateVariable: String {
    /// First Name Last Name or Last Name First name
    case name = "NAME"
    /// e.g. Solution Architect
    case jobTitle = "JOBTITLE"
    /// summary of who I am and what I am good at
    case jobSummary = "SUMMARY"
    /// email address
    case email = "EMAIL"
    /// phone number
    case phone = "PHONE"
    /// linkedin id - begind: https://www.linkedin.com/in/
    case linkedIn = "LINKEDIN_ID"
    /// github repo
    case github = "GITHUB"
    /// e.g. Annecy - France
    case place = "PLACE"
    
    case technos = "TECHNOS"
    
    public static func parse(variableName: String, applicationName: String?) -> CVTemplateVariable? {
        if let asIsVal = CVTemplateVariable(rawValue: variableName) { return asIsVal }
        guard let appName = applicationName else {
            return CVTemplateVariable(rawValue: variableName)
        }
        let prefixEndPos = (variableName.count-appName.count-1)
        if prefixEndPos < 0 { return nil }
        let varName = variableName.prefix(prefixEndPos)
        return CVTemplateVariable(rawValue: String(varName))
    }
    
}

/// Latex element prefixes recognized by the parser
/// mapped to a particular templating behaviour
enum CVTemplateBlockType: String {
    /// This is the prefix of sections in the document
    /// Each section has a tab in the data source
    /// which is used to fill the document
    case sectionPrefix = "\\section"
}

/// Supported enumeration types
/// Each enum present in the template has
/// a tab with data available in the data source
/// which is used to fill the document
enum CVTemplateSection: String {
    case strengths = "Strengths"
    case educationAndCertifications = "Education \\& Certifications"
    /// \education{fr_name}{fr_delivered_by}{fr_year}
    /// \education{en_name}{en_delivered_by}{en_year}
    case education = "Education"
    /// \certification{fr_name}{fr_delivered_by}{fr_year}
    /// \certification{en_name}{en_delivered_by}{en_year}
    case certifications = "Certifications"
    /// \langLevel{fr_name}{fr_level}
    /// \langLevel{en_name}{en_level}
    case languages = "Languages"
    case technologies = "Technologies"
    case experience = "Experience"
    
    func separator() -> String {
        switch self {
        case .technologies:
            return " • "
        default:
            return "\n"
        }
    }
}

