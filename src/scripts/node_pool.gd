class_name NodePool 

var _pool: Array[Node] = []
var _pool_index: int = 0

func _init(scene: PackedScene, size: int):
	for i in range(size):
		_pool.append(scene.instantiate())

func get_next() -> Node:
	var node = _pool[_pool_index]
	_pool_index += 1
	if _pool_index >= _pool.size():
		_pool_index = 0
	return node

func get_at(index: int) -> Node:
	return _pool[index]

func get_size() -> int:
	return _pool.size()
