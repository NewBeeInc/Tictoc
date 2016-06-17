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

public let NOW = Tictoc().now
public let MOMENT = Tictoc().moment
public let TODAY = Tictoc().today

// MARK: -
public extension Tictoc {
	/// current now
	public var now: Time { return time(nil) }

	/// current moment
	public var moment: Moment {
		var tv = timeval()
		gettimeofday(&tv, nil)
		return Double(tv.tv_sec) + Double(tv.tv_usec) / Double(1_000_000)
	}

	/// today
	public var today: Day {
		var now = self.now
		var now_tm = localtime(&now).pointee
		now_tm.tm_hour = 0
		now_tm.tm_min = 0
		now_tm.tm_sec = 0
		let s = timelocal(&now_tm)
		let e = s + SEC_PER_DAY
		return s..<e
	}
}

