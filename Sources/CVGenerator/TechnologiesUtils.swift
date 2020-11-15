//
//  TechnologiesUtils.swift
//  CVGenerator
//
//  Created by bsbl on 08.03.20.
//

import Foundation

class TechnologiesUtils {
    
    public static func normalizeRawTechnos(_ rawListOfTechnos: String) -> [String] {
        var set = Set<String>()
        return rawListOfTechnos
            .replacingOccurrences(of: "\r\n", with: "|")
            .replacingOccurrences(of: "\n", with: "|")
            .replacingOccurrences(of: "\r", with: "|")
            .replacingOccurrences(of: ";", with: "|")
            .replacingOccurrences(of: ",", with: "|")
            .replacingOccurrences(of: "\u{A0}", with: " ")
            .replacingOccurrences(of: "[0-9]+(\\.x)?", with: "", options:
                .regularExpression)
            .replacingOccurrences(of: "([0-9]+-[0-9]+)", with: "", options:
            .regularExpression)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "\\(.+\\)", with: "", options: .regularExpression)
            .split(separator: "|").map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .map {
                String($0.split(separator: " ")[0]) }
            .map { $0.capitalized }
            .compactMap {
                set.insert($0).inserted ? $0 : nil
            }
    }
    
    public static func formatDate(lang: String, month: Int, year: Int) throws -> String {
        let date = try getDate(month: month, year: year)
        guard let locale = TechnologiesUtils.langLocalesMapping[lang] else {
            throw CVError.dataError("Undefined locale for lang: \(lang)")
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        fmt.locale = locale
        return fmt.string(from: date)
    }

    public static func getDate(month: Int, year: Int) throws -> Date {
        let dateString = "01/\(month)/\(year)"
        let fmt = DateFormatter()
        fmt.locale = TechnologiesUtils.langLocalesMapping["fr"]
        fmt.dateFormat = "dd/MM/yyyy"
        guard let date = fmt.date(from: dateString) else {
            throw CVError.dataError("Cannot parse specified date: \(dateString)")
        }
        return date
    }
    
    static func buildPeriodExpression(lang: String, fromMonth: Int, fromYear: Int, toMonth: Int, toYear: Int) throws -> String {
        let from = try formatDate(lang: lang, month: fromMonth, year: fromYear)
        let to = try formatDate(lang: lang, month: toMonth, year: toYear)
        ///TODO SBL: configurable period format
        return "\(from) - \(to)"
    }
    
    enum DateType {
        case from
        case to
    }
    
    static func monthYearToDate(_ mmm_slash_YYYY: String, type: DateType) throws -> Date {
        let mmmYYYY = try extractMonthAndYear(monthYearText: mmm_slash_YYYY, throwErrorIfEmpty: true)
        let firstDayOfMonth = try getDate(month: mmmYYYY.month, year: mmmYYYY.year)
        switch type {
        case .from:
            return firstDayOfMonth
        case .to:
            return Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfMonth)!)!
        }
    }
    
    /// If `throwErrorIfEmpty` is true then `dataError` is thrown
    /// otherwise, the current month and year is returned.
    static func extractMonthAndYear(monthYearText: String, throwErrorIfEmpty: Bool) throws -> (month: Int, year: Int) {
        if monthYearText == "" {
            if throwErrorIfEmpty {
                throw CVError.dataError("mmm/YYYY is empty!")
            }
            else {
                let now = Date()
                return (month: Calendar.current.component(Calendar.Component.month, from: now),
                        year: Calendar.current.component(Calendar.Component.year, from: now))
            }
        }
        else {
            let monthsYearFrom = monthYearText.split(separator: "/")
            if monthsYearFrom.count != 2 {
                throw CVError.dataError("Invalid mmm/YYYY date: \(monthYearText)")
            }
            let nf = NumberFormatter()
            guard let month = nf.number(from: String(monthsYearFrom[0])), let year = nf.number(from: String(monthsYearFrom[1])) else {
                throw CVError.dataError("Number format error while parsing mmm/YYYY date: \(monthYearText)")
            }
            return (month: month.intValue, year: year.intValue)
        }
    }
    

    static var langLocalesMapping = [
        "fr": Locale(identifier: "fr_FR"),
        "en": Locale(identifier: "en_EN")
    ]
    
}
