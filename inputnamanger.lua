local inputmanager = {}
-- What will happen in here is that some keys/scancodes/joystick inputs will be mapped into specific actions. So that if someone wants to check if the action "left"
-- has one corresponding keyboard being pressed, the input manager can return true.

-- The inputmanager also maps out some values like how much a gamepad stick is leaning on the left or the right ect. (Which are variable)

inputmanager.actions = {} -- For all actions, shows all keys connected
inputmanager.scancodes = {} -- Reverse of actions, shows all scancodes connected to a certain action
inputmanager.keys = {} -- Reverse of actions, shows all actions connected
inputmanager.mouse_buttons = {} -- Reverse of actions, shows all actions connected
inputmanager.joysticks = {} -- joysticks can have variable inputs such as an axis's direction and how much is it pushed in that direction

--
-->Mappers
--
function inputmanager:map_scancode(action, key)
    if not self.actions[action] then
        self.actions[action] = {}
    end
    if not self.scancodes[key] then
        self.scancodes[key] = {}
    self.actions[action][#self.actions+1] = {"s", key, love.keyboard.isScancodeDown(key)} -- First element is type of information, rest is info
    -- since this is a scancode, the first element will be "s"
    self.scancodes[key][#self.scancodes+1] = action;
end

function inputmanager:map_key(action, key)
    if not self.actions[action] then
        self.actions[action] = {}
    end
    if not self.keys[key] then
        self.keys[key] = {}
    self.actions[action][#self.actions+1] = {"s", key, love.keyboard.isDown(key)} -- First element is type of information, rest is info
    -- since this is a scancode, the first element will be "s"
    self.keys[key][#self.keys+1] = action;
end

function inputmanager:map_mouse(action, mousebutton)
    if not self.actions[action] then
        self.actions[action] = {}
    end
    if not self.keys[key] then
        self.keys[key] = {}
    self.actions[action][#self.actions+1] = {"s", key, love.keyboard.isDown(key)} -- First element is type of information, rest is info
    -- since this is a scancode, the first element will be "s"
    self.keys[key][#self.keys+1] = action;
end

function inputmanager:map_joystick(action, joystick_number, joystick_button )

end
--
-->Demappers
--


--
-->Getters
--

--
-->To be used directly in main.lua
--

-- The following functions must be Used directly in main.lua in their corresponding functions, AND before anything else that uses the input manager
function inputmanager:keypressed(key, scancode, isrepeat)

end

function inputmanager:keyreleased(key, scancode, isrepeat)

end

function inputmanager:mousepressed(x, y, button, istouch)

end

function inputmanager:joystickadded( Joystick )

end

function inputmanager:joystickremoved( Joystick )
    -- We can use Joystick:getID() to remove it from the joysticks list stored
end

function inputmanager:joystickpressed( Joystick, button )

end

function inputmanager:joystickreleased(Joystick, button )

end

function inputmanager:joystickaxis(Joystick, axis, value)

end

function inputmanager:joystickhat(Joystick, hat, direction)

end

return inputmanager;