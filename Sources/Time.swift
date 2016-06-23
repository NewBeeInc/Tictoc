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

public typealias Time   = time_t
public typealias Moment = Double
public typealias Tm     = tm
public typealias Tv     = timeval

public typealias Duration     = Range<Moment>
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

	/**
	get a Day value from short date string in format "yyyy-mm-dd", please note that any format other than this will get a nil return value;

	- parameter date: a string of date, shall be in format "yyyy-mm-dd";

	- returns: return Day value if date string is valid, otherwise nil
	*/
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

	public func isTheDayToday(_ day: Day) -> Bool {
		return day == tToday
	}

	public func isTheDayYesterday(_ day: Day) -> Bool {
		return day == tYesterday
	}

	public func isTheDayTomorrow(_ day: Day) -> Bool {
		return day == tTomorrow
	}

	public func isToday(_ time: Time) -> Bool {
		return tToday.contains(time)
	}

	public func isTomorrow(_ time: Time) -> Bool {
		return tTomorrow.contains(time)
	}

	public func isYesterday(_ time: Time) -> Bool {
		return tYesterday.contains(time)
	}
}

extension Time {

	/**
	convert a Time value into date string in format "yyyy-mm-dd"

	- returns: return date string in format "yyyy-mm-dd"
	*/
	public func toDateShort() -> String {
		var t = self
		let tm = localtime(&t).pointee
		let y = tm.tm_year + 1900
		let m = tm.tm_mon + 1
		let d = tm.tm_mday
		return "\(y)-\(m < 10 ? "0" : "")\(m)-\(d < 10 ? "0" : "")\(d)"
	}

	/**
	convert a Time value into time string in format "HH:MM:SS"

	- returns: return time string in format "HH:MM:SS"
	*/
	public func toTimeShort() -> String {
		var t = self
		let tm = localtime(&t).pointee
		let H = tm.tm_hour
		let M = tm.tm_min
		let S = tm.tm_sec
		return "\(H >= 10 ? "" : "0")\(H):\(M >= 10 ? "" : "0")\(M):\(S >= 10 ? "" : "0")\(S)"
	}

	/**
	convert a Time value into full date/time string in format "yyyy-mm-dd HH:MM:SS"

	- returns: return full date/time string in format "yyyy-mm-dd HH:MM:SS"
	*/
	public func toDateFull() -> String {
		return "\(self.toDateShort()) \(self.toTimeShort())"
	}
}

