/datum/bsp_node
	var/x
	var/y
	var/width
	var/height

	var/datum/bsp_node/parent
	var/datum/bsp_node/left
	var/datum/bsp_node/right

/datum/bsp_tree
	/// Minimum width of node in tree
	var/min_width
	/// Minimum height of node in tree
	var/min_height

	/// Base of our tree
	var/datum/bsp_node/root
	/// Leaves of our tree (for faster traversal)
	var/list/datum/bsp_node/leaves

	New(x=1, y=1, width=300, height=300, min_width=10, min_height=10)
		..()
		if(width <= 0 || height <= 0 || min_width < 1 || min_height < 1)
			return

		src.root = new
		src.leaves = list()
		root.x = x
		root.y = y
		root.width = width
		root.height = height

		src.min_width  = min_width
		src.min_height = min_height

		build_tree()

	/// Split a node based on the tree's requirements
	proc/split_node(datum/bsp_node/node)
		// If we are sufficiently small enough we no longer need to split
		if(node.width <= src.min_width*2 && node.height <= src.min_height*2)
			src.leaves += node
			return

		// Determine which way we need to split
		var/split_x = prob(50)
		if(node.width > node.height && node.width > src.min_width*2 )
			split_x = TRUE
		else if(node.height > src.min_height*2)
			split_x = FALSE

		node.left = new/datum/bsp_node
		node.left.parent = node
		node.right = new/datum/bsp_node
		node.right.parent = node

		if(split_x)
			// Slice Width
			node.left.x = node.x
			node.left.y = node.y
			node.left.width = rand(src.min_width, node.width - src.min_width)
			node.left.height = node.height

			node.right.x = node.x + node.left.width
			node.right.y = node.y
			node.right.width = node.width - node.left.width
			node.right.height = node.height
		else
			// Slice Height
			node.left.x = node.x
			node.left.y = node.y
			node.left.width = node.width
			node.left.height = rand(src.min_height, node.height - src.min_height)

			node.right.x = node.x
			node.right.y = node.y + node.left.height
			node.right.width = node.width
			node.right.height = node.height - node.left.height

		. = node

	/// Determine if two nodes are adjacent
	proc/are_nodes_adjacent(datum/bsp_node/a, datum/bsp_node/b)
		if(a.y < b.y + b.height && a.y + a.height > b.y)
			if(a.x + a.width == b.x)  // A|B to the right
				. = TRUE
			if(b.x + b.width == a.x)  // B|A to the left
				. = TRUE
		if(a.x < b.x + b.width && a.x + a.width > b.x)
			if(a.y + a.height == b.y)  // A/B above
				. = TRUE
			if(b.y + b.height == a.y)  // B/A below
				. = TRUE

	/// Get all leaves from a given node
	proc/get_leaves(datum/bsp_node/root)
		. = list()
		var/list/datum/bsp_node/nodes_to_divide = list(root)
		while(length(nodes_to_divide))
			var/datum/bsp_node/current = nodes_to_divide[length(nodes_to_divide)]
			nodes_to_divide -= current

			if(current.left)
				nodes_to_divide += current.left
				nodes_to_divide += current.right
			else
				. += current

	/// Generate a tree based on the stored criteria
	proc/build_tree()
		var/list/datum/bsp_node/nodes_to_divide = list(src.root)
		while(length(nodes_to_divide))
			var/datum/bsp_node/current = nodes_to_divide[length(nodes_to_divide)]
			nodes_to_divide -= current

			var/datum/bsp_node/result = split_node(current)
			if(result)
				nodes_to_divide += result.left
				nodes_to_divide += result.right

