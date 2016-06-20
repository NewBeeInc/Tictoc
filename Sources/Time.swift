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

public typealias Time = time_t
public typealias Moment = Double
public typealias Tm   = tm
public typealias Tv   = timeval

public typealias Timeinterval = Range<Time>
public typealias Minute       = Range<Time>
public typealias Hour         = Range<Time>
public typealias Day          = Range<Time>
public typealias Week         = Range<Time>
public typealias Month        = Range<Time>
public typealias Year         = Range<Time>

let SEC_PER_DAY = 86400
let SEC_PER_HOUR = 3600
let SEC_PER_MINUTE = 60

public let tNow = Tictoc().now
public let tMoment = Tictoc().moment
public let tToday = Tictoc().today
public let tThisHour = Tictoc().thisHour
public let tThisMinute = Tictoc().thisMinute

// MARK: -
public extension Tictoc {
	/// current now
	public var now: Time {
		return time(nil)
	}
	private var nowTm: Tm {
		var now = self.now
		return localtime(&now).pointee
	}

	/// current moment
	public var moment: Moment {
		var tv = timeval()
		gettimeofday(&tv, nil)
		return Double(tv.tv_sec) + Double(tv.tv_usec) / Double(1_000_000)
	}

	/// today
	public var today: Day {
		var now_tm = self.nowTm
		now_tm.tm_hour = 0
		now_tm.tm_min = 0
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_DAY
		return s..<e
	}

	/// this hour
	public var thisHour: Hour {
		var now_tm = self.nowTm
		now_tm.tm_min = 0
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_HOUR
		return s..<e
	}

	/// this minute
	public var thisMinute: Minute {
		var now_tm = self.nowTm
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_MINUTE
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


}

