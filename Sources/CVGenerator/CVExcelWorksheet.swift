//
//  CVExcelWorksheet.swift
//  CVGenerator
//
//  Created by bsbl on 15.02.20.
//

import Foundation
import CoreXLSX

class CVExcelWorksheet {
    
    private let worksheet: Worksheet
    private let sharedString: SharedStrings
    var headers: [String] = []
    private var rows: [Row] = []
    
    init(worksheet ws: Worksheet, sharedStrings ss: SharedStrings) {
        worksheet = ws
        sharedString = ss
        prepareHeadersAndRows()
    }
    
    func data() -> [[String]] {
        return rows.map {
            values(cells: $0.cells)
        }
    }
    
    private func prepareHeadersAndRows() {
        guard let allRows = worksheet.data?.rows, let firstRow = allRows.first else {
            headers = []
            rows = []
            return
        }
        headers = values(cells: firstRow.cells)
        rows = Array(allRows.dropFirst())
    }
    
    private func values(cells: [Cell]) -> [String] {
        cells.map {cell in
            switch (cell.type, cell.value) {
            case (.some(let val1), .some(let val2)) where val1.rawValue == "s" && Int(val2) != nil:
                let index = Int(val2)!
                return CVDataNormalizer.normalizeData(
                    sharedString.items[index].text ?? (sharedString.items[index].richText.map({$0.text ?? ""}).joined(separator:""))
                )
            default:
                return CVDataNormalizer.normalizeData(cell.value ?? "")
            }
        }
    }
    
}
