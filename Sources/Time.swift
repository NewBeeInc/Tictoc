//
//  Time.swift
//  Tictoc
//
//  Created by Ke Yang on 6/16/16.
//
//

#if os(Linux) || os(FreeBSD)
	import Glibc
#else
	import Darwin
#endif

import Foundation
import GCD

public typealias Time   = time_t
public typealias Moment = Double
public typealias Tm     = tm
public typealias Tv     = timeval

piblic typealias Duration     = Range<Moment>
public typealias Timeinterval = Range<Time>
public typealias Minute       = Range<Time>
public typealias Hour         = Range<Time>
public typealias Day          = Range<Time>
public typealias Week         = Range<Time>
public typealias Month        = Range<Time>
public typealias Year         = Range<Time>

/// number of sec in a day
let SEC_PER_DAY = 86400
/// number of sec in a hour
let SEC_PER_HOUR = 3600
/// number of sec in a minute
let SEC_PER_MINUTE = 60

/// now in Int
public let tNow = Tictoc().now
/// now in Double
public let tMoment = Tictoc().moment
/// today in Range of Time
public let tToday = Tictoc().today
/// this hour in Range of Time
public let tThisHour = Tictoc().thisHour
/// this minute in Range of Time
public let tThisMinute = Tictoc().thisMinute
/// tomorrow in Range of Time
public let tTomorrow = Tictoc().tomorrow
/// yesterday in Range of Time
public let tYesterday = Tictoc().yesterday

// MARK: -
public extension Tictoc {
	/// now in Time
	public var now: Time {
		return time(nil)
	}
    /// now in Tm
	private var nowTm: Tm {
		var now = self.now
		return localtime(&now).pointee
	}

	/// now in Moment
	public var moment: Moment {
		var tv = timeval()
		gettimeofday(&tv, nil)
		return Double(tv.tv_sec) + Double(tv.tv_usec) / Double(1_000_000)
	}

	/// today in Range of Time
	public var today: Day {
		var now_tm = self.nowTm
		now_tm.tm_hour = 0
		now_tm.tm_min = 0
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_DAY
		return s..<e
	}

	/// tomorrow in Range of Time
	public var tomorrow: Day {
		let s = self.today.upperBound
		let e = s + SEC_PER_DAY
		return s..<e
	}

	/// yesterday in Range of Time
	public var yesterday: Day {
		let e = self.today.lowerBound
		let s = e - SEC_PER_DAY
		return s..<e
	}

	/// this minute in Range of Time
	public var thisMinute: Minute {
		var now_tm = self.nowTm
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_MINUTE
		return s..<e
	}

	/// this hour in Range of Time
	public var thisHour: Hour {
		var now_tm = self.nowTm
		now_tm.tm_min = 0
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_HOUR
		return s..<e
	}

	/**
	get an interval of specified seconds before now

	- parameter c: count of seconds specified

	- returns: return Timeinterval range
	*/
	public func secondsAgo(_ c: Int) -> Time {
		return tNow - c
	}

	/**
	get an interval of specified minutes before now

	- parameter c: count of minutes specified

	- returns: return Timeinterval range
	*/
	public func minutesAgo(_ c: Int) -> Time {
		return tNow - c * SEC_PER_MINUTE
	}

	/**
	get an interval of specified hours before now
	
	- parameter c: count of hours specified

	- returns: return Timeinterval range
	*/
	public func hoursAgo(_ c: Int) -> Time {
		return tNow - c * SEC_PER_HOUR
	}

	public func dayFromShortDate(_ date: String) -> Day? {
		let nMatch = Regex.ShortDate.numberOfMatches(in: date, options: .reportProgress, range: NSMakeRange(0, date.characters.count))
		guard nMatch > 0
			else { return nil }
		let comps = date.components(separatedBy: "-")
		let y = comps[0]
		let m = comps[1]
		let d = comps[2]

		var t_tm = tm()
		t_tm.tm_year = (Int32(y) ?? 1900) - 1900
		t_tm.tm_mon = max((Int32(m) ?? 0) - 1, 0)
		t_tm.tm_mday = Int32(d) ?? 0
		t_tm.tm_hour = 0
		t_tm.tm_min = 0
		t_tm.tm_sec = 0
		t_tm.tm_gmtoff = 28800
		let s = timelocal(&t_tm)
		let e = s + SEC_PER_DAY
		return s..<e
	}


}

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

