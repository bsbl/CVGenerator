//
//  CVSourceSection.swift
//  CVGenerator
//
//  Created by bsbl on 08.02.20.
//

import Foundation

class CVSourceSection {
    let section: CVTemplateSection
    var source: [CVSourceSectionItem]
    
    init(section: CVTemplateSection) {
        self.section = section
        self.source = []
    }

    init(section: CVTemplateSection, source: [CVSourceSectionItem]) {
        self.section = section
        self.source = source
    }

    func addSectionItem(item: CVSourceSectionItem) {
        source.append(item)
    }
}

class CVSourceSectionItem {
    /// identifier of the section item.
    /// required to reconcile multiple rows
    /// into the same multivalued item.
    let id: String
    /// The prefix to use to create the section item
    let prefix: String
    /// Indicate whether the value is wrapped into curly braces: {value}
    let isWrappedInCurlyBraces: Bool
    /// The values of the section item
    private(set) var values: [String]
    
    init(id: String, prefix: String, values: [String], isWrappedInCurlyBraces: Bool = true) {
        self.id = id
        self.prefix = prefix
        self.values = values
        self.isWrappedInCurlyBraces = isWrappedInCurlyBraces
    }

    init(id: String, prefix: String, expectedValuesCount: Int, isWrappedInCurlyBraces: Bool = true) {
        self.id = id
        self.prefix = prefix
        self.values = (1...expectedValuesCount).map { _ in return "" }
        self.isWrappedInCurlyBraces = isWrappedInCurlyBraces
    }

    func addValue(pos: Int, value: String) {
        values[pos] = value
    }
    
    func build() -> String {
        return values.reduce(prefix) { res,val -> String in
            return res + (isWrappedInCurlyBraces ? "{\(val)}" : val)
        }
    }
}
