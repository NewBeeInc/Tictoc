//
//  Task.swift
//  Tictoc
//
//  Created by Ke Yang on 6/24/16.
//
//

#if os(Linux)
	import SwiftGlibc
	import CDispatch
#else
	import Dispatch
#endif

import Foundation

internal protocol TaskDelegate: class {
	func task(didFinish task: Task) -> Void
}

class Task: Hashable {

	var identifier: String = ""

	var hashValue: Int {
		return (self.identifier ?? "").hashValue
	}
}

func ==(lhs: Task, rhs: Task) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

class CountDownTask: Task {

	/// a number counting down from
	private var from: Int?

	/// a number count down to, default is 0
	private var to: Int = 0

	/// count down interval in second, default is 1.0
	private var interval: Double = 1.0

	/// a block called in progress of counting down
	private var at: ((Int) -> Void)?

	/// a block called after counting down finished
	private var finish: (() -> Void)?

	/// a concurrent queue on which the task is attached
	#if os(Linux)
	private var queue: dispatch_queue_t?
	#else
	private var queue: DispatchQueue?
	#endif

	/// delegate
	internal weak var delegate: TaskDelegate?

	/**
	initializer
	don't call this method directly, user -init(_:from:to:interval:at:finish:) instead
	- returns: a CountDownTask instance
	*/
	private override init() {
		super.init()
	}

	/**
	designed initializer

	- parameter identifier: task identifier
	- parameter from:       a number counting down from
	- parameter to:         a number count down to, default is 0
	- parameter interval:   count down interval in second, default is 1.0
	- parameter at:         a block called in progress of counting down
	- parameter finish:     a block called after counting down finished
	- returns: a CountDownTask instance
	*/
	convenience init(identifier: String, from: Int, to: Int = 0, interval: Double = 1.0, at: ((at: Int) -> Void)?, finish: (() -> Void)?) {
		self.init()
		self.identifier = identifier
		self.from       = from
		self.to         = to
		self.interval   = interval
		self.at         = at
		self.finish     = finish
		#if os(Linux)
			self.queue  = dispatch_queue_create(self.identifier, DISPATCH_QUEUE_CONCURRENT)
		#else
			self.queue  = DispatchQueue(label: self.identifier, attributes: DispatchQueueAttributes.concurrent, target: nil)
		#endif
	}
}

internal extension CountDownTask {

	/**
	start counting down

	- parameter from:  a number count down from
	*/
	internal func startCountDown(from: Int) {
		#if os(Linux)
			dispatch_async(self.queue!, {[weak self] () -> Void in
				self?.countDown(from)
				})
		#else
			self.queue!.async { [weak self] in
				self?.countDown(at: from)
			}
		#endif
	}

	/**
	countind at

	- parameter at: a number counting down at
	*/
	internal func countDown(at: Int) {
		print("countTo = \(at)")
		if at == 0 {
			self.stopCountDown()
			return
		}
		#if os(Linux)
			dispatch_async(dispatch_get_main_queue()) { () -> Void in
				self.at?(at)
			}
			let step = dispatch_time(DISPATCH_TIME_NOW, Int64((interval) * Double(NSEC_PER_SEC)))
			dispatch_after(step, self.queue!) {[weak self] () -> Void in
				self?.countDown(at - 1)
			}
		#else
			DispatchQueue.main.async { [weak self] in
				self?.at?(at)
			}
			self.queue!.after(when: DispatchTime.now() + interval) {  [weak self] in
				self?.countDown(at: at - 1)
			}
		#endif
	}

	/**
	counting down finished
	*/
	internal func stopCountDown() {
		#if os(Linux)
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			self.finish?()
			if self.delegate?.respondsToSelector("taskWithDidFinish:") == true {
				self.delegate!.task!(didFinish: self)
			}
		}
		#else
		DispatchQueue.main.async {
			self.finish?()
			self.delegate?.task(didFinish: self)
		}
		#endif
	}

	/**
	override the target task with interval, block at and block finish
	- parameter target: the target task
	*/
	internal func overrides(target: CountDownTask) {
		target.interval = self.interval
		target.at       = self.at
		target.finish   = self.finish
	}
}
