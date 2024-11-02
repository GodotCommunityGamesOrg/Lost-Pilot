class_name UtilityFunctions

## UtilityFunctions class:
## a class containing static functions for global use.


static func get_all_Children(root_node, stop_class = null) -> Array[Node]: ## Gets all of the parents children (grand children, great grand children, ect)
	var nodes: Array[Node] = []
	for node in root_node.get_children():
		nodes.append(node)
		if node.get_child_count() > 0 and node != stop_class:
			nodes += get_all_Children(node, stop_class)
	return nodes
