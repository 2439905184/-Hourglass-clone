extends Node


# Checks whether git is available on the system.
func is_available() -> bool:
	return OS.execute("git", ["--version"], true) == 0


# Initializes a directory as a git repository.
func init_repository(dir: String) -> void:
	OS.execute("git", ["init", dir], true)


# For cloning repositories.
#
# The operation will be performed in a separate thread, and a signal (either
# finished or error) will be emitted when it is complete. Note that you must
# call start() to start the operation, after you have connected to the signals.
class CloneOperation:
	extends Node


	signal finished()
	signal error()

	var url: String
	var dest: String
	var thread: Thread


	func _init(url: String, dest: String):
		self.url = url
		self.dest = dest


	func start() -> void:
		print("Cloning ", url, " into ", dest)
		self.thread = Thread.new()
		thread.start(self, "_thread_function", "Wafflecopter")


	func _thread_function(userdata):
		if not Git.is_available():
			call_deferred("_finish", -2)
		else:
			var exitcode := OS.execute("git", ["clone", url, dest], true)
			call_deferred("_finish", exitcode)


	func _finish(result: int) -> void:
		if result == 0:
			print("Clone succeeded")
			emit_signal("finished")
		elif result == -2:
			print("Clone failed! Git is not installed.")
			emit_signal("error", tr("Git is not installed."))
		else:
			print("Clone failed!")
			emit_signal("error", tr("An unexpected error occurred."))

		# Thread has already finished by the time _finish() is called
		# (because of call_deferred), but we need to call this to clean
		# up
		self.thread.wait_to_finish()
