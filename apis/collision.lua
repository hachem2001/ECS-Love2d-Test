local collision = {}

function collision.rec_rec(x,y,w,h,x2,y2,w2,h2) -- collision of 2 rectangles
	return x2-x<w and x2-x>-w2 and y2-y<h and y2-y>-h2
end

function collision.point_rec(x, y, x2, y2, w2, h2) -- check if a point is inside a rectangle
	return x-x2<w2 and y-y2<h2 and x-x2>0 and y-y2>0
end

return collision