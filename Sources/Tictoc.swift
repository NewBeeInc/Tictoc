#if os(Linux)
	import CDispatch
#else
	import Dispatch
#endif

/**
 *	Tictoc is a light weight framework providing time releated functions,
 *  for now, it's designed for Swift backend on Linux.
 **/
public class Tictoc {

	/// singleton instance
	private class var manager: Tictoc {
		struct Static {
			static let instance: Tictoc = Tictoc()
		}
		return Static.instance
	}

	private var taskPool: Set<Task> = Set<Task>()

	private init() {}
}

public extension Tictoc {

	/**
	register a new count down task and fire it immediately if doesn't exist; otherwise pick up the existed one, sync and resume;

	- parameter identifier: task ID
	- parameter from:       a number count down from
	- parameter to:         a number count down to, default is 0
	- parameter interval:   count down interval in second, default is 1.0
	- parameter at:         a block called in progress of counting down
	- parameter finish:     a block called after counting down finished
	*/
	public func registerCountDown(identifier: String, from: Int, to: Int = 0, interval: Double = 1.0, at: ((Int) -> Void)?, finish: (() -> Void)?) {
		let countDownTask = CountDownTask(identifier: identifier, from: from, to: to, interval: interval, at: at, finish: finish)
		if !self.taskPool.contains(countDownTask) {
			self.taskPool.insert(countDownTask)
//			countDownTask.delegate = self
			countDownTask.startCountDown(from: from)
		} else {
			let index = self.taskPool.index(of: countDownTask)
			if let task = self.taskPool[index!] as? CountDownTask {
				countDownTask.overrides(target: task)
			}
		}
	}

	/**
	check if specific task is in counting

	- parameter identifier: task ID
	- returns: a boolean value indicates if specific task is in counting
	*/
	public func isTaskCounting(identifier: String) -> Bool {
		for task in self.taskPool {
			if task.identifier == identifier {
				return true
			}
		}
		return false
	}
}

// MARK: - TaskDelegate

extension Tictoc: TaskDelegate {

	/**
	called after specific task finished

	- parameter task: a specific task instance
	*/
	internal func task(didFinish task: Task) {
		self.taskPool.remove(task)
	}
}
