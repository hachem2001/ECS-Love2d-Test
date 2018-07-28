-- PREREQUESTIES :
-- colorutils

local levelselect = {}
local colorutils = colorutils or require("colorutils")

-- SETUP levelselect

--#########################################--
--###############           ###############--
--############### VARIABLES ###############--
--############### ######### ###############--
--#########################################--

levelselect.font = love.graphics.getFont()
levelselect.states = {}
levelselect.levels = {}
levelselect.pos_dim = {x=50, y=50, w=love.graphics.getWidth()-100, h=love.graphics.getHeight()-100} -- Where the level selector will be drawn
levelselect.pos_dim_levels = {x=50,y=100,w=love.graphics.getWidth()-100, h=love.graphics.getHeight()-200} -- Where the levels will be displayed

levelselect.pos_dim_states = {x=50,y=50,w=love.graphics.getWidth()-100,h=50} -- where the states (buttons indicating delete, edit, select ... will be shown)

levelselect.pos_dim_pageselector = {x=50,y=levelselect.pos_dim.y+love.graphics.getHeight()-150,w=love.graphics.getWidth()-100, h=50} -- Where the player can switch to next page ect..  will be displayed

levelselect.level_wd, levelselect.level_hd = 5 , 5 -- Max number of levels in a row, and in a column.
levelselect.seperatorx,levelselect.seperatory = 10, 10
levelselect.level_w, levelselect.level_h = (levelselect.pos_dim_levels.w-(2+levelselect.level_wd)*levelselect.seperatorx)/levelselect.level_wd, (levelselect.pos_dim_levels.h-(2+levelselect.level_hd)*levelselect.seperatory)/levelselect.level_hd -- Box dimensions of each level

levelselect.pages = 0 -- Number of pages for the level selector
levelselect.currpage = 1 -- Current displayed page
levelselect.currentselected = 1 -- Used for keyboard selection. Up/down movements and such will be handy here.
levelselect.currstate = 1 -- Current state used (example : state "play" which will make you play the map everytime you select it)

levelselect.palette = { -- Color palette of the level selector
	background1						= colorutils:neww(80	,	50	,	80	,	255	),
	background2 					= colorutils:neww(100	,	100	,	200	,	255	),

	levels	=	{
		insideU							=	colorutils:neww(255	,	255	,	255	,	255 ), -- At game start
		outlineU						=	colorutils:neww(255	,	255	,	255	,	255	),
		textU								= colorutils:neww(255	,	255	,	255	,	255	),

		inside1							=	colorutils:neww(70	,	90	,	160	,	140 ), -- Normal Color
		outline1						=	colorutils:neww(150	,	150	,	160	,	250	),
		text1								= colorutils:neww(255	,	255	,	255	,	255	),

		inside2							=	colorutils:neww(90		,	70	,	140	,	150 ), -- Color of level box when hovered
		outline2						=	colorutils:neww(70		,	90	,	160	,	240	),
		text2								= colorutils:neww(180	,	180	,	180	,	255	),

		inside_actioned			= colorutils:neww(200	,	80	,	90	,	180	), -- When held with key (pressed)
		outline_actioned		= colorutils:neww(200	,	80	,	90	,	255	),
		text_actioned				= colorutils:neww(255	,	255	,	255	,	255	),
	},
	
	states	=	{
		insideU							=	colorutils:neww(255	,	255	,	255	,	255 ), -- At game start
		outlineU						=	colorutils:neww(255	,	255	,	255	,	255	),
		textU								= colorutils:neww(255	,	255	,	255	,	255	),

		inside1							=	colorutils:neww(70	,	90	,	160	,	140 ), -- Normal Color
		outline1						=	colorutils:neww(150	,	150	,	160	,	250	),
		text1								= colorutils:neww(255	,	255	,	255	,	255	),

		inside2							=	colorutils:neww(90		,	70	,	140	,	150 ), -- Color of level box when hovered
		outline2						=	colorutils:neww(70		,	90	,	160	,	240	),
		text2								= colorutils:neww(180	,	180	,	180	,	255	),

		inside_actioned			= colorutils:neww(200	,	80	,	90	,	180	), -- When held with key (pressed)
		outline_actioned		= colorutils:neww(200	,	80	,	90	,	255	),
		text_actioned				= colorutils:neww(255	,	255	,	255	,	255	),

	},
}


-- END SETUP levelselect

--#########################################--
--##############             ##############--
--############## ADDITIONERS ##############-- FUNCTIONS FOR ADDING NEW LEVELS AND STATE CHANGERS
--############## ########### ##############--
--#########################################--

function levelselect:add_state(textt, func) -- example : delete, edit, play ... aka mode of selection.
	-- func will recieve the content of the level, which is really the filepath and the levelindex, as arguments
	local prevx, prevy, prevw, prevh
	if self.states[#self.states] then
		prevx, prevy, prevw, prevh = self.states[#self.states].x, self.states[#self.states].y, self.states[#self.states].w, self.states[#self.states].h		
	else
		prevx, prevy, prevw, prevh = self.pos_dim_states.x+2, self.pos_dim_states.y + 2 , 0, self.pos_dim_states.h-4
	end
	
	local text = love.graphics.newText(self.font, textt)
	
	local m = #self.states+1
	
	self.states[#self.states+1] = {text=text, rawtext=textt, x=prevx+prevw+2, y=prevy, w=text:getWidth()*2, h=prevh, func = func, insidecolor = colorutils:copy(self.palette.states.insideU), outlinecolor = colorutils:copy(self.palette.states.outlineU), textcolor=colorutils:copy(self.palette.states.textU)}
	
	return m
end

function levelselect:add_level(name, filepath) -- adds a level to the levelselector.
	local m = self.levels[#self.levels]
	local prevx, prevy, prevw, prevh

	if m~= nil then
		prevx, prevy, prevw, prevh = m.x, m.y, m.w, m.h
	end
	
	local mm = #self.levels
	
	if m==nil or mm%(self.level_wd*self.level_hd)==0 then --or prevy+prevh+self.seperatory>=self.pos_dim_levels.y+self.pos_dim_levels.h-self.seperatory then
		self.pages = self.pages + 1
		x = self.pos_dim_levels.x+self.seperatorx
		y = self.pos_dim_levels.y+self.seperatory
		w, h = levelselect.level_w, levelselect.level_h
	elseif m and prevx+prevw+self.seperatorx>=self.pos_dim_levels.x+self.pos_dim_levels.w-levelselect.level_w-self.seperatorx then
		x = self.pos_dim_levels.x+self.seperatorx
		y = prevy + prevh + self.seperatory
		w, h = levelselect.level_w, levelselect.level_h
	else
		x = prevx + prevw + self.seperatorx
		y = prevy
		w, h = levelselect.level_w, levelselect.level_h
	end
	
	self.levels[mm+1] = {text=love.graphics.newText(self.font, name), filepath=filepath, x=x, y=y, w=w, h=h, actioned=((mm+1)==self.currentselected),page=self.pages}
	return mm+1
end

function levelselect:remove_level(levelindex)
	self.levels[levelindex] = nil
	self:reset_level_boxes() -- resets all levels.

end

function levelselect:draw_level(lvl)
	love.graphics.push()
		local state = 0
		local mousex, mousey = love.mouse.getPosition()
		if lvl.actioned then
			state = 1
		elseif mousex>lvl.x and mousex<lvl.x+lvl.w and mousey>lvl.y and mousey<lvl.y+lvl.h then
			state = 2
		end
		love.graphics.setColor(state==0 and self.palette.levels.inside1 or (state==2 and self.palette.levels.inside2 or (state==1 and self.palette.levels.inside_actioned)))
		love.graphics.rectangle("fill", lvl.x, lvl.y, lvl.w, lvl.h)
		love.graphics.setColor(state==0 and self.palette.levels.outline1 or (state==2 and self.palette.levels.outline2 or (state==1 and self.palette.levels.outline_actioned)))
		love.graphics.rectangle("line", lvl.x, lvl.y, lvl.w, lvl.h)
		love.graphics.setColor(state==0 and self.palette.levels.text1 or (state==2 and self.palette.levels.text2 or (state==1 and self.palette.levels.text_actioned)))
		love.graphics.draw(lvl.text, math.ceil(lvl.x+lvl.w/2-lvl.text:getWidth()/2), math.ceil(lvl.y+lvl.h/2-lvl.text:getHeight()/2))
	love.graphics.pop()
end

function levelselect:draw_state(state)
	love.graphics.push()
		love.graphics.setColor(state.insidecolor)
		love.graphics.rectangle("fill", state.x, state.y, state.w, state.h, 5)
		love.graphics.setColor(state.outlinecolor)
		love.graphics.rectangle("fill", state.x, state.y, state.w, state.h, 5)
		love.graphics.setColor(state.textcolor)
		love.graphics.draw(state.text, math.ceil(state.x+state.w/2-state.text:getWidth()/2), math.ceil(state.y+state.h/2-state.text:getHeight()/2))
	love.graphics.pop()
end

--#########################################--
--###############           ###############--
--############### MODIFIERS ###############-- USED FOR CUSTOMIZING THE LEVELSELECTOR USING SIMPLE FUNCTIONS
--############### ######### ###############--
--#########################################--

function levelselect:set_position(x, y)
	local prevx, prevy = self.pos_dim.x, self.pos_dim.y
	self.pos_dim.x = x
	self.pos_dim.y = y
	self.pos_dim_levels.x = x
	self.pos_dim_levels.y = y+(self.pos_dim.h)/500 * 50
	
	self.pos_dim_states.x = x
	self.pos_dim_states.y = y

	self.pos_dim_pageselector.x = x
	self.pos_dim_pageselector.y = y + self.pos_dim.h - (self.pos_dim.h)/500 * 50

	--self.level_wd, self.level_hd = 5 , 5 -- Max number of levels in a row, and in a column.
	--self.seperatorx,self.seperatory = 10, 10
	self.level_w, self.level_h = (self.pos_dim_levels.w-(2+self.level_wd)*self.seperatorx)/self.level_wd, (self.pos_dim_levels.h-(2+self.level_wd)*self.seperatory)/self.level_hd -- Box dimensions of each level
	
	for k,v in pairs(self.levels) do
		self.levels[k].x = v.x + x-prevx
		self.levels[k].y = v.y + y-prevy
	end
	
	for k,v in pairs(self.states) do
		self.states[k].x = v.x + x-prevx
		self.states[k].y = v.y + y-prevy
	end
end

function levelselect:set_size(w, h)
	self.pos_dim.w = w
	self.pos_dim.h = h
	
	self.pos_dim_states.w = w
	self.pos_dim_states.h = h/500*50
	
	self.pos_dim_levels.y = self.pos_dim.y+(h)/500 * 50
	self.pos_dim_levels.w = w
	self.pos_dim_levels.h = h-h/500*100
		
	self.pos_dim_pageselector.w = w
	self.pos_dim_pageselector.y = self.pos_dim.y + h - (h)/500 * 50
	self.pos_dim_pageselector.h = (h)/500 * 50
	
	self.level_w, self.level_h = (self.pos_dim_levels.w-(2+self.level_wd)*self.seperatorx)/self.level_wd, (self.pos_dim_levels.h-(2+self.level_hd)*self.seperatory)/self.level_hd -- Box dimensions of each level
	
	self:reset_state_boxes()
	self:reset_level_boxes()
end

function levelselect:set_grid(wdivisions, hdivisions, xseperation, yseperation)
	self.level_wd, self.level_hd = wdivisions , hdivisions -- Max number of levels in a row, and in a column.
	self.seperatorx,self.seperatory = xseperation or self.seperatorx, yseperation or self.seperatory
	self.level_w, self.level_h = (self.pos_dim_levels.w-(2+self.level_wd)*self.seperatorx)/self.level_wd, (self.pos_dim_levels.h-(2+self.level_wd)*self.seperatory)/self.level_hd -- Box dimensions of each level
	
	self:reset_state_boxes()
	self:reset_level_boxes()
end

function levelselect:reset_level_boxes() -- resets their positions, this is mainly done after modifying width/height/grid options.
	local localsave = {}
	for k,v in pairs(self.levels) do
		localsave[k] = {}
		for k2,v2 in pairs(v) do
			localsave[k][k2] = v2
		end
	end
	
	self.levels = {}
	self.pages = 0
	self.currpage = 1
	for k,v in pairs(localsave) do
		self:add_level("", v.filepath)
		self.levels[#self.levels].text = v.text
	end
end

function levelselect:reset_state_boxes()
	local localsave = {}
	for k,v in pairs(self.states) do
		localsave[k] = {}
		for k2,v2 in pairs(v) do
			localsave[k][k2] = v2
		end
	end
	
	self.states = {}
	for k,v in pairs(localsave) do
		self:add_state(v.rawtext, v.func)
	end
end

--#########################################--
--################        #################--
--################ EVENTS #################-- USED FOR HANDLING DRAW UPDATE MOUSE AND KEYBOARD EVENTS
--################ ###### #################--
--#########################################--

function levelselect:draw()
	
	for k,v in pairs(self.levels) do
		if v.page == self.currpage then
			self:draw_level(v)
		end
	end
	for k,v in pairs(self.states) do
		self:draw_state(v)
	end
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+80, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2)
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+40, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2-20)
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+40, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2+20)
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-80, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2)
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-40, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2-20)
	
	love.graphics.setColor(1,1,1,0.4)
	love.graphics.line(self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-20, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2,self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-40, self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2+20)
	
	love.graphics.printf(self.currpage.."/"..self.pages, math.floor(self.pos_dim_pageselector.x), math.floor(self.pos_dim_pageselector.y+self.pos_dim_pageselector.h/2-10), math.floor(self.pos_dim_pageselector.w), "center")
end

function levelselect:update(dt)
	local dtt = dt*2
	local mousex, mousey = love.mouse.getPosition()
	if game_is_focused then
		for k,v in pairs(self.states) do
			if self.currstate == k then
				v.insidecolor		= v.insidecolor(self.palette.states.inside_actioned, 2*dtt)
				v.outlinecolor	= v.outlinecolor(self.palette.states.outline_actioned, 2*dtt)
				v.textcolor			= v.textcolor(self.palette.states.text_actioned, 2*dtt)
			elseif mousex>v.x and mousex<v.x+v.w and mousey>v.y and mousey<v.y+v.h then
				v.insidecolor		= v.insidecolor(self.palette.states.inside2, dtt)
				v.outlinecolor	= v.outlinecolor(self.palette.states.outline2, dtt)
				v.textcolor			= v.textcolor(self.palette.states.text2, dtt)
			else
				v.insidecolor		= v.insidecolor(self.palette.states.inside1, dtt)
				v.outlinecolor	= v.outlinecolor(self.palette.states.outline1, dtt)
				v.textcolor			= v.textcolor(self.palette.states.text1, dtt)
			end
		end
	end
end

function levelselect:mousepressed(x, y, button, isTouch)
	if x<self.pos_dim_pageselector.x+self.pos_dim_pageselector.w/3 and x>self.pos_dim_pageselector.x and y<self.pos_dim_pageselector.y+self.pos_dim_pageselector.h and y>self.pos_dim_pageselector.y then
		self.currpage = (self.currpage-2)%self.pages + 1
	elseif x>self.pos_dim_pageselector.x+self.pos_dim_pageselector.w-self.pos_dim_pageselector.w/3 and x<self.pos_dim_pageselector.x+self.pos_dim_pageselector.w and y<self.pos_dim_pageselector.y+self.pos_dim_pageselector.h and y>self.pos_dim_pageselector.y then
		self.currpage = self.currpage%self.pages + 1
	end
	for k,v in pairs(self.states) do
		if button == 1 and x<v.x+v.w and x>v.x and y<v.y+v.h and y>v.y then
			self.currstate = k
			return
		end
	end
	for k,v in pairs(self.levels) do
		if button == 1 and x<v.x+v.w and x>v.x and y<v.y+v.h and y>v.y then
			v.actioned = true
			if self.currentselected ~= k then
				self.levels[self.currentselected].actioned = false
				self.currentselected = k
			end
			return
		end
	end
end

function levelselect:mousereleased(x, y, button, isTouch)
	for k,v in pairs(self.levels) do
		if v.actioned and x<v.x+v.w and x>v.x and y<v.y+v.h and y>v.y then
			self.states[self.currstate].func(v.filepath, k) -- Runs the state function on the clicked on map
		elseif not self.currentselected==k and v.actioned then
			v.actioned = false
		end
	end
end


function levelselect:keypressed(key, scancode, isrepeat)
	if scancode == "up" and self.currentselected > self.level_wd then
		self.levels[self.currentselected].actioned = false
		self.currentselected = self.currentselected - self.level_wd
		self.levels[self.currentselected].actioned = true
		self.currpage = math.ceil(self.currentselected/(self.level_wd * self.level_hd))		
	elseif scancode == "down" and self.currentselected+self.level_wd<#self.levels then
		self.levels[self.currentselected].actioned = false
		self.currentselected = self.currentselected + self.level_wd
		self.levels[self.currentselected].actioned = true
		self.currpage = math.ceil(self.currentselected/(self.level_wd * self.level_hd))		
	elseif scancode == "left" and self.currentselected > 1 then
		self.levels[self.currentselected].actioned = false
		self.currentselected = self.currentselected - 1
		self.levels[self.currentselected].actioned = true
		self.currpage = math.ceil(self.currentselected/(self.level_wd * self.level_hd))
	elseif scancode == "right" and self.currentselected < #self.levels then
		self.levels[self.currentselected].actioned = false
		self.currentselected = self.currentselected + 1
		self.levels[self.currentselected].actioned = true
		self.currpage = math.ceil(self.currentselected/(self.level_wd * self.level_hd))
	elseif scancode == "return" then
		self.states[self.currstate].func(self.levels[self.currentselected].filepath, self.currentselected) -- Runs the state function on the selected map
	end
end

function levelselect:keyreleased(key, scancode, isrepeat)
	
end


--#########################################--
--############## ########## ###############--
--############## CHILL ZONE ###############--
--############## ########## ###############--
--#########################################--

return levelselect