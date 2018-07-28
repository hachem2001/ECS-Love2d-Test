local audiomanager = {}
audiomanager.sounds = {}
audiomanager.playsounds = false


function audiomanager:add(path, name, typ)
	self.sounds[name] = love.audio.newSource(path, typ or "stream")
end

function audiomanager:play(name)
	if audiomanager.playsounds then
		self.sounds[name]:seek(0)
		love.audio.play(self.sounds[name])
	end
end

--audiomanager:add("audio/dead1.ogg", "jump")
--audiomanager:add("audio/switch.ogg", "switch")
--audiomanager:add("audio/click2.ogg", "clickout")
--audiomanager:add("audio/click5.wav", "uiclick")

return audiomanager