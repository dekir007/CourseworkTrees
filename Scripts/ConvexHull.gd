extends Node
class_name ConvexHull

var p0 := Vector2(0, 0)

func nextToTop(S:Array):
	return S[-2]
 
func distSq(p1:Vector2, p2:Vector2):
	return ((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))

func orientation(p, q, r):
	var val = ((q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y))
	if val == 0:
		return 0  # collinear
	elif val > 0:
		return 1  # clock wise
	else:
		return 2  # counterclock wise

func compare(p1:Vector2, p2:Vector2):
	# Find orientation
	var o = orientation(p0, p1, p2)
	if o == 0:
		if distSq(p0, p2) >= distSq(p0, p1):
			return true
		else:
			return false
	else:
		if o == 2:
			return true
		else:
			return false

func convexHull(points:Array[Vector2]):
	var n := points.size()
	# Find the bottommost point
	var ymin = points[0].y
	var min = 0
	for i in range(1, n):
		var y = points[i].y
 
		# Pick the bottom-most or choose the left
		# most point in case of tie
		if ((y < ymin) or
			(ymin == y and points[i].x < points[min].x)):
			ymin = points[i].y
			min = i
 
	# Place the bottom-most point at first position
	var tmp = points[0]
	points[0]=points[min]
	points[min]=tmp
	#points[0], points[min] = points[min], points[0]
 
	# Sort n-1 points with respect to the first point.
	# A point p1 comes before p2 in sorted output if p2
	# has larger polar angle (in counterclockwise
	# direction) than p1
	p0 = points[0]
	points.sort_custom(compare)
	#points = sorted(points, key=cmp_to_key(compare))

	# If two or more points make same angle with p0,
	# Remove all but the one that is farthest from p0
	# Remember that, in above sorting, our criteria was
	# to keep the farthest point at the end when more than
	# one points have same angle.
	var m = 1  # Initialize size of modified array
	for i in range(1, n):
	   
		# Keep removing i while angle of i and i+1 is same
		# with respect to p0
		while ((i < n - 1) and (orientation(p0, points[i], points[i + 1]) == 0)):
			i += 1
 
		points[m] = points[i]
		m += 1  # Update size of modified array
 
	# If modified array of points has less than 3 points,
	# convex hull is not possible
	if m < 3:
		return
 
	# Create an empty stack and push first three points
	# to it.
	var S : Array[Vector2] = []
	S.append(points[0])
	S.append(points[1])
	S.append(points[2])
 
	# Process remaining n-3 points
	for i in range(3, m):
	   
		# Keep removing top while the angle formed by
		# points next-to-top, top, and points[i] makes
		# a non-left turn
		while ((len(S) > 1) and
		(orientation(nextToTop(S), S[-1], points[i]) != 2)):
			S.pop_back()
		S.append(points[i])
 	
	return S
	
	# Now stack has the output points,
	# print contents of stack
	while S.size() > 0:
		var p : = S[-1]
		print("(" + str(p.x) + ", " + str(p.y) + ")")
		S.pop_back()



