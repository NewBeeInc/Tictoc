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
	(注册一个新的倒数计时任务并立即执行该任务; 如果该任务已存在, 则进行同步)
	- parameter identifier: task ID(任务ID)
	- parameter from:       a number count down from(起始计数)
	- parameter to:         a number count down to, default is 0(终止计数, 默认为0)
	- parameter interval:   count down interval in second, default is 1.0(计数间隔, 单位秒, 默认为1.0)
	- parameter at:         a block called in progress of counting down(倒计时过程中的回调)
	- parameter finish:     a block called after counting down finished(倒计时结束时的回调)
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
	(查询指定ID的任务是否正在执行)
	- parameter identifier: task ID(任务ID)
	- returns: a boolean value indicates if specific task is in counting(返回true代表正在执行, 反之则返回false)
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
	(任务结束时调用协议代理的此方法)
	- parameter task: a specific task instance(任务)
	*/
	internal func task(didFinish task: Task) {
		self.taskPool.remove(task)
	}
}
