class_name CallableList

var callables: Array[Callable] = []

func emit(pos):
	for callable in callables:
		if callable.is_valid():
			await callable.call(pos)
