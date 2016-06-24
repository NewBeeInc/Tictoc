//
//  Task.swift
//  Tictoc
//
//  Created by Ke Yang on 6/24/16.
//
//

import Foundation
import Dispatch

internal protocol TaskDelegate {
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

	/// a number counting down from(起始计数)
	private var from: Int?

	/// a number count down to, default is 0(终止计数, 默认为0)
	private var to: Int = 0

	/// count down interval in second, default is 1.0(计数间隔, 单位秒, 默认为1.0)
	private var interval: Double = 1.0

	/// a block called in progress of counting down(倒计时过程中的回调)
	private var at: ((Int) -> Void)?

	/// a block called after counting down finished(倒计时结束时的回调)
	private var finish: (() -> Void)?

	/// a concurrent queue on which the task is attached(计时任务执行的队列)
	private var queue: DispatchQueue?

	/// delegate
//	internal var delegate: TaskDelegate

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
	(快速构造方法)
	- parameter identifier: task identifier(任务ID)
	- parameter from:       a number counting down from(起始计数)
	- parameter to:         a number count down to, default is 0(终止计数, 默认为0)
	- parameter interval:   count down interval in second, default is 1.0(计数间隔, 单位秒, 默认为1.0)
	- parameter at:         a block called in progress of counting down(倒计时过程中的回调)
	- parameter finish:     a block called after counting down finished(倒计时结束时的回调)
	- returns: a CountDownTask instance(返回一个倒数计时任务实例)
	*/
	convenience init(identifier: String, from: Int, to: Int = 0, interval: Double = 1.0, at: ((at: Int) -> Void)?, finish: (() -> Void)?) {
		self.init()
		self.identifier = identifier
		self.from       = from
		self.to         = to
		self.interval   = interval
		self.at         = at
		self.finish     = finish
		self.queue      = DispatchQueue(label: self.identifier, attributes: DispatchQueueAttributes.concurrent, target: nil)
	}
}

internal extension CountDownTask {

	/**
	start counting down
	(开始倒数计时)
	- parameter from:  a number count down from(起始计数)
	*/
	internal func startCountDown(from: Int) {
		self.queue!.async { [weak self] in
			self?.countDown(at: from)
		}
	}

	/**
	countind at
	(倒数计时至)
	- parameter at: a number counting down at(倒数至某个数)
	*/
	internal func countDown(at: Int) {
		print("countTo = \(at)")
		if at == 0 {
			self.stopCountDown()
			return
		}

		DispatchQueue.main.async { [weak self] in
			self?.at?(at)
		}

		self.queue!.after(when: DispatchTime.now() + interval) {  [weak self] in
			self?.countDown(at: at - 1)
		}
	}

	/**
	counting down finished
	(结束倒数计时)
	*/
	internal func stopCountDown() {
		DispatchQueue.main.async {
			self.finish?()
//			if self.delegate.responds(to: Selector(("taskWithDidFinish:"))) == true {
//				self.delegate.task(didFinish: self)
//			}
		}
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
