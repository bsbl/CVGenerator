//
//  TechnologiesOrderer.swift
//  CVGenerator
//
//  Created by bsbl on 01.03.20.
//

import Foundation

struct ExperiencePeriod {
    var from: Date
    var to: Date
    var interval: Double {
        Double(Calendar.current.dateComponents([.month], from: from, to: to).month!)
    }
    let technos: [String]
}
/**
 * Weights distribution:
 * ---------------------
 * 1      6,18046971569839
 * 2      5,2109659685335
 * 3      4,77299343771778
 * 4      4,50438278202489
 * 5      4,31598164036902
 * 6      4,17335925618173
 * 7      4,05992771604906
 * 8      3,96653830351037
 * 9      3,88765832276822
 * 10    3,81970970206264
 * 11    3,76025701499778
 * 12    3,70757434809163
 * 13    3,66039800626029
 * 14    3,61777742236397
 */
struct ExperiencesPeriods {
    var periods: [ExperiencePeriod] = []
    var totalMonths: Double {
        periods.reduce(0) { $0 + $1.interval }
    }
    var periodsCoeficient: [Double] {
        let overall = totalMonths
        var startOfPeriod = overall
        return periods.map { period in
            //(((36÷36)+(25÷36))÷2)×12
            let periodCoef = (((startOfPeriod/overall)+((startOfPeriod-period.interval+1.0)/overall))/2.0) * period.interval
            //print(">> ((((\(startOfPeriod)/\(overall))+((\(startOfPeriod)-\(period.interval)+1.0)/\(overall)))/2.0) * \(period.interval)) = \(periodCoef)")
            startOfPeriod = startOfPeriod - period.interval
            return periodCoef
        }
    }
    mutating func add(_ period: ExperiencePeriod) {
        periods.append(period)
    }
    func orderedTechnos() -> [String] {
        var technos: [String:[Double]] = [:]
        for (index,coef) in periodsCoeficient.enumerated() {
            let period = periods[index]
            //(1÷(1,618+LOG10($A2)))×10
            var itemPosition = 1.0
            period.technos.forEach { techno in
                let techWeight = (1/(1.618+log10(itemPosition)))*10
                //print(">> \(techno) -> \(techWeight), \(coef)")
                if !technos.contains(where: { $0.key == techno }) {
                    technos[techno] = [techWeight * coef]
                }
                else {
                    technos[techno]?.append(techWeight*coef)
                }
                itemPosition = itemPosition + 1.0
            }
        }
        log("Un-ordered technos: \(technos)")
        return technos.sorted { kv1, kv2 -> Bool in
            kv1.value.reduce(0) { $0 + $1 } >= kv2.value.reduce(0) { $0 + $1 }
        }.map { $0.key }
    }
}
