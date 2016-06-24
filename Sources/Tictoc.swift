
public class Tictoc {

	/// singleton instance
	private class var manager: Tictoc {
		struct Static {
			static let instance: Tictoc = Tictoc()
		}
		return Static.instance
	}

	private init() {}
}
