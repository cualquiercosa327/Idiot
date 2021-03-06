dialog = class("dialog")

function dialog:init(character, text, autoscroll, sign, screen)
	self.drawText = ""
	self.current = 0

	self.color = color

	self.active = true
	self.static = true

	self.x = 2
	self.height = 18
	self.width = gameFunctions.getWidth() - 4
	self.y = 2

	self.timer = 0
	self.delay = 0.05

	self.lifeTime = 0

	self.currentText = 1

	self.text = text

	self.doScroll = false
	self.stop = false
	self.maxChars = 48

	if dialogs[character] then
		self.character = dialogs[character]
	end

	self.canScroll = false
	self.activated = false
	self.autoscroll = autoscroll
	self.sign = sign

	self.screen = screen or "top"
end

function dialog:activate()
	self.activated = true
end

function dialog:update(dt)
	if not self.activated then
		return
	end

	--if self.currentText <= #self.texts then
	if self.current <= #self.text and not self.doScroll then
		self.timer = self.timer + dt
		if self.timer > self.delay then
			self.drawText = self.drawText .. self.text:sub(self.current, self.current)
			self.current = self.current + 1
			self.timer = 0
		end
	else
		self.canScroll = true
		if self.autoscroll then
			self.doScroll = true
		end

		if self.doScroll then
			self.lifeTime = self.lifeTime + dt
			if self.lifeTime > 1 then
				if self.sign then
					self.sign:reset()
				end
				self.activated = false
				self.remove = true
			end
		end
	end
end

function dialog:scrollText()
	if not self.activated then
		return
	end

	if not self.canScroll then
		if eventSystem:isRunning() then
			self.drawText = self.text
			self.current = #self.text+1
		end
		return
	end

	if not self.doScroll then
		scrollSound:play()
		self.doScroll = true
	end
end

function dialog:draw()
	love.graphics.setScreen(self.screen)

	if self.activated then
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", self.x, self.y, love.graphics.getWidth() - 4, self.height)
		love.graphics.setColor(255, 255, 255, 255)

		local off = 0
		if self.character then
			off = 26
			love.graphics.draw(self.character, (self.x + 13) - self.character:getWidth() / 2, self.y + (self.height / 2) - self.character:getHeight() / 2)
		end

		love.graphics.print(self.drawText, self.x + 4 + off, self.y + 3 + (self.height / 2) - signFont:getHeight() / 2)

		if #self.drawText == #self.text and not self.doScroll and not self.autoscroll then
			love.graphics.draw(scrollArrow, love.graphics.getWidth() - 18, self.y + (self.height - 4) + math.sin(love.timer.getTime() * 8))
		end
	end
end