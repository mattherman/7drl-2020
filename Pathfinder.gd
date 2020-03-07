var map: TileMap
var tile_size = Constants.TILE_SIZE
const directions = [
	Vector2.RIGHT,
	Vector2.LEFT,
	Vector2.UP,
	Vector2.DOWN,
#	Vector2.UP + Vector2.RIGHT,
#	Vector2.UP + Vector2.LEFT,
#	Vector2.DOWN + Vector2.RIGHT,
#	Vector2.DOWN + Vector2.LEFT
]

class_name Pathfinder
func _init(m):
	map = m

func find_path(start_pos, end_pos):
	var came_from = { start_pos: null }
	var cost_so_far = { start_pos: 0 }

	var frontier = [PriorityNode.new(start_pos, 0)]
	var current
	while !frontier.empty():
		current = frontier.pop_front().position
		if current == end_pos:
			break
		for next_pos in get_neighbors(current):
			var new_cost = cost_so_far[current] + 1
			if !cost_so_far.has(next_pos) || new_cost < cost_so_far[next_pos]:
				cost_so_far[next_pos] = new_cost
				var priority = new_cost + heuristic(end_pos, next_pos)
				frontier.append(PriorityNode.new(next_pos, priority))
				came_from[next_pos] = current
		frontier.sort_custom(PrioritySort, "sort_ascending")

	var path = [current]
	var prev = came_from[current]
	while prev != null:
		path.push_front(prev)
		prev = came_from[prev]
	return path

func get_neighbors(pos):
	var neighbors = []
	for dir in directions:
		var neighbor = pos + (dir * tile_size)
		if map.get_cellv(neighbor) == TileMap.INVALID_CELL:
			neighbors.append(neighbor)
	return neighbors

func heuristic(a: Vector2, b: Vector2):
	return a.distance_to(b)

class PriorityNode:
	var position: Vector2
	var priority: int
	func _init(node_pos, node_priority):
		position = node_pos
		priority = node_priority
		
class PrioritySort:
	static func sort_ascending(a, b):
		return a.priority < b.priority
