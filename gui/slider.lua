-- PREREQUESTIES :
-- colorutils

--#########################--
--########CODESTART########--
--#########################--

local slider = {}

-- Parameters
slider.x, slider.y, slider.w, slider.h, slider.offsetx, slider.offsety = 200, 200, 200, 200, 10, 0
slider.sliide = {x=slider.x+1, y=slider.y+1, w=10, tw=8, th=10, h=slider.h-2, pos=0} -- pos varies between 0 and 1
slider.startedclick = false
slider.text, slider.textt = love.graphics.newText(love.graphics.getFont(), 'This is an example test'), 'This is an example text'

slider.image_data = love.image.newImageData(200, 200)
slider.image = love.graphics.newImage(slider.image_data)

slider.focused = false

-- Color Palette
slider.palette = {
	slide = {
		box = colorutils:neww(155,155,155,255),
		box_highlighed = colorutils:neww(180,180,180,255),
	},
	content = {
		text = colorutils:neww(180,150,150,255),
		text_focused = colorutils:neww(180,180,150,255),
	},
	background = colorutils:neww(160,150,140,140),
	contour = colorutils:neww(170,170,170,255),
}


-- Functions
slider.funct = function(self)
	return function()love.graphics.rectangle('fill', self.x+self.sliide.w, self.y, self.w-self.sliide.w, self.h)end
end

function slider:draw()
	local mx, my = love.mouse.getPosition();
	love.graphics.push()
	
	love.graphics.setColor(self.palette.contour)
	love.graphics.rectangle("line",self.x, self.y, self.w, self.h)
	love.graphics.rectangle("line",self.sliide.x, self.sliide.y, self.sliide.w, self.sliide.h)
	
	local tx, ty, tw, th = self.sliide.x+1, self.sliide.y + self.sliide.pos*(self.sliide.h-self.sliide.th), self.sliide.tw, self.sliide.th
	
	if self.startedclick or mx<tx+tw and my<ty+th and mx>tx and my>ty then
		love.graphics.setColor(self.palette.slide.box_highlighed)
	else
		love.graphics.setColor(self.palette.slide.box)
	end
	love.graphics.rectangle("fill",tx, ty, tw, th)
	
	love.graphics.stencil(self:funct(), 'replace', 1)
	
	love.graphics.setStencilTest("greater", 0)
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(self.image, self.x+self.sliide.w+self.offsetx, self.y-self.sliide.pos*(math.max(0,self.image:getHeight()-self.sliide.h))+self.offsety)
	
	love.graphics.setColor(self.focus and self.palette.content.text_focused or self.palette.content.text)
	love.graphics.draw(self.text, self.x+self.sliide.w+self.offsetx, self.y-self.sliide.pos*(math.max(0,self.text:getHeight()-self.sliide.h))+self.offsety)

	do
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 20)
	end
	love.graphics.setStencilTest()
	
	
	love.graphics.pop()
end

function slider:update(dt)
	local mx, my = love.mouse.getPosition()
	
	if self.startedclick then
		self.sliide.pos = math.max(math.min( (my-self.startedclick[2])/(self.sliide.h-self.sliide.th) + self.startedclick[3],1), 0)
	end
	
	if self.focus then
		if love.keyboard.isDown("down") then
			self.sliide.pos = math.max(math.min(1, self.sliide.pos + 120*dt/(math.max(self.image:getHeight(), self.image:getHeight()))),0)
		elseif love.keyboard.isDown("up")then
			self.sliide.pos = math.max(math.min(1, self.sliide.pos - 120*dt/(math.max(self.image:getHeight(), self.image:getHeight()))),0)
		end
	end
end

function slider:mousepressed(x, y, b, istouch)
	local mx, my = x, y
	if mx>self.sliide.x and my>self.sliide.y and mx-self.sliide.x<self.sliide.w and my-self.sliide.y<self.sliide.h then
		self.startedclick={x,y, self.sliide.pos}
	end
	if mx>self.x+self.sliide.tw and my>self.y and mx<self.x+self.w and my<self.y+self.h then
		self.focus = true
	else
		self.focus = false
	end
end

function slider:mousereleased(x, y, b, istouch)
	self.startedclick = false
end

function slider:set_text(txt, size)
	if size then
		local font = love.graphics.newFont(size)
		self.text = love.graphics.newText(font,"")
	end
	self.text:setf(txt, self.w-self.sliide.w-self.offsetx, "left")
	self.textt = txt
	
	self.sliide.th = math.min(1, self.sliide.h/math.max(self.image:getHeight(),self.text:getHeight())) * self.sliide.h
end

function slider:set_image(img, resize)
	slider.image_data = img:getData()
	slider.image = img
	
	if resize then
		slider:set_dimensions(img:getWidth(), img:getHeight())
	end
	
	self.sliide.th = math.min(1, self.sliide.h/math.max(self.image:getHeight(),self.text:getHeight())) * self.sliide.h
	print(self.image:getHeight())
	print(self.sliide.th)
end

function slider:set_position(x,y)
	self.x, self.y = x or self.x , y or self.y
	self.sliide.x,self.sliide.y = self.x+1, self.y+1
end

function slider:set_dimensions(w,h, tw)
	self.w = w or self.w
	self.h = h or self.h
	self.sliide.h = self.h - 2
	self.text:setf(self.textt, self.w-self.sliide.w-self.offsetx, "left")
	self.sliide.th = math.min(1, self.sliide.h/math.max(self.image:getHeight(),self.text:getHeight())) * self.sliide.h
	self.pos = self.text:getHeight()/self.h
	self.sliide.tw = tw or self.sliide.tw
	self.sliide.w = self.sliide.tw + 2
end

slider:set_text([[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse bibendum, libero ut semper auctor, purus mauris lobortis libero, vitae eleifend justo augue et enim. Suspendisse eleifend nunc vel imperdiet tempus. Nam hendrerit, tortor quis lobortis consequat, urna neque lacinia est, sed sodales dui odio vel sapien. Aenean vitae dui libero. Donec molestie sed ex sollicitudin blandit. Integer at sagittis lectus, et pharetra sem. Quisque sapien quam, posuere sed ex vitae, gravida scelerisque tellus. Pellentesque at ante nec purus vestibulum elementum. In velit est, laoreet sed erat nec, pulvinar molestie risus. Donec tincidunt vel felis sed iaculis. In neque mauris, tempor in laoreet at, ornare id justo. Aliquam luctus faucibus egestas. Quisque mattis metus ac quam sollicitudin, nec imperdiet mauris vulputate. Duis sed lectus ex. Praesent ut lacus id mi commodo sodales vitae in massa.

Integer semper nunc consectetur pellentesque auctor. Donec hendrerit elit vel tincidunt placerat. Etiam a suscipit enim, sit amet rutrum erat. Phasellus elit erat, posuere non massa ac, aliquam fringilla quam. Donec neque nisi, ornare eu ante eu, volutpat scelerisque enim. Curabitur tempor erat quis erat bibendum lobortis. Nam quis ante sodales, suscipit ex nec, luctus turpis. Etiam aliquam tincidunt nisi, tempus sagittis odio fermentum ac.]], 25)

slider:set_position(50,100)
slider:set_dimensions(width-100,height-200)

--#########################--
--########Chillzone########--
--#########################--

return slider