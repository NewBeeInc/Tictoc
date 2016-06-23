//
//  Regex.swift
//  Tictoc
//
//  Created by Ke Yang on 6/23/16.
//
//

import Foundation

struct RegexPattern {
	static let FullDate = "[0-2]{1}\\d{3}\\-((((0[13578]{1})|(1[02]{1}))\\-((0[1-9]{1})|([12]{1}\\d{1})|(3[01]{1})))|(((0[469]{1})|(11))\\-((0[1-9]{1})|([12]{1}\\d{1})|(30)))|(02\\-((0[1-9]{1})|([12]{1}\\d{1}))))\\s(([01]{1}\\d{1})|2[0-3]{1}):[0-5]{1}\\d{1}:[0-5]{1}\\d{1}"
	static let ShortDate = "[0-2]{1}\\d{3}\\-((((0[13578]{1})|(1[02]{1}))\\-((0[1-9]{1})|([12]{1}\\d{1})|(3[01]{1})))|(((0[469]{1})|(11))\\-((0[1-9]{1})|([12]{1}\\d{1})|(30)))|(02\\-((0[1-9]{1})|([12]{1}\\d{1}))))"
}

struct Regex {
	#if os(Linux)
	static let FullDate = try! NSRegularExpression(pattern: RegexPattern.FullDate, options: .caseInsensitive)
	static let ShortDate = try! NSRegularExpression(pattern: RegexPattern.ShortDate, options: .caseInsensitive)
	#else
	static let FullDate = try! RegularExpression(pattern: RegexPattern.FullDate, options: .caseInsensitive)
	static let ShortDate = try! RegularExpression(pattern: RegexPattern.ShortDate, options: .caseInsensitive)
	#endif
}
