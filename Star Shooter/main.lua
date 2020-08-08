-- Made by Aman Hafeez
--Space Invaders Game

	-- To make images look sharp
	love.graphics.setDefaultFilter('nearest','nearest')

	enemy = {}
	enemies_controller = {}
	enemies_controller.enemies = {}
	enemies_controller.image = love.graphics.newImage('enemy.png')
	particle_systems = {}
	particle_systems.list = {}
	particle_systems.image = love.graphics.newImage('blast.png')

-- creating particles when enemies die
function particle_systems:spawn(x, y)
	local ps = {}
	ps.x = x
	ps.y = y
	ps.ps = love.graphics.newParticleSystem(particle_systems.image, 3)
	ps.ps:setParticleLifetime(5, 5)
	ps.ps:setEmissionRate(5)
	ps.ps:setSizeVariation(1)
	ps.ps:setLinearAcceleration(20, 20, 20, 20)
	ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
	table.insert(particle_systems.list, ps)
end

-- drawing the explosion when enemy dies
function particle_systems:draw()
	for _, v in pairs(particle_systems.list) do
		love.graphics.draw(v.ps, v.x, v.y)
	end
end

function particle_systems:update(dt)
	for _, v in pairs(particle_systems.list) do
		v.ps:update(dt)
	end
end

-- getting rid of the explosion
--function particle_systems:cleanup()

--end

-- Collision function
function checkCollisions(enemies, bullets)
	for i, e in ipairs(enemies) do
		for _,b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				particle_systems:spawn(e.x, e.y)
				table.remove(enemies, i)
				for _, v in pairs(particle_systems.list) do
					love.graphics.draw(v.ps, v.x, v.y)
				end
			end
		end
	end
end


-- loading variables to use or tables or functions
function love.load()

	-- put background music 
	local music = love.audio.newSource('Music.mp3', 'static')
	music:setLooping(true)
	love.audio.play(music)

	-- game over screen
	game_over = false 

	-- game win screen
	game_win = false

	-- adding a background 
	background_image = love.graphics.newImage('background.png')

	-- making tables for player 
	player = {}
	player.x = 0
	player.y = 540
	player.bullets = {}
	player.cooldown = 20
	player.speed = 10
	player.image = love.graphics.newImage('player.png')
	player.fire_sound = love.audio.newSource('Laser2.wav', 'static')

	-- making a function  
	player.fire = function()
		if player.cooldown <= 0 then
		-- for playing the sound
		love.audio.play(player.fire_sound)
		player.cooldown = 20
		bullet = {}
		bullet.x = player.x + 27
		bullet.y = player.y + 25
		table.insert(player.bullets, bullet)
		end
	end

	-- spawning multiple enemies
	for i = 0, 10 do
		enemies_controller:spawnEnemy(i * 75, 0)
	end
end

-- function for enemy
function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 60
	enemy.height = 80
	enemy.bullets = {}
	enemy.cooldown = 20
	enemy.speed = 5
	table.insert(self.enemies, enemy)
end


function enemy:fire()
		if self.cooldown <= 0 then
		self.cooldown = 20
		bullet = {}
		bullet.x = self.x + 72.5
		bullet.y = self.y
		table.insert(self.bullets, bullet)
		end
end

-- function for delta time to update as user inputs strokes on keyboard
function love.update(dt)

	-- bullet cooldown 
	player.cooldown = player.cooldown - 1

	-- Moving the player 
	if love.keyboard.isDown("right") then
		player.x = player.x + player.speed
	elseif love.keyboard.isDown("left") then
		player.x = player.x - player.speed
	end

	-- Firing a bullet
	if love.keyboard.isDown("space") then
		player.fire()
	end

	-- winning screen
	if #enemies_controller.enemies == 0 then
		game_win = true
	end

	-- making the bullet move
	for i,b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets, i)
		end
		b.y = b.y - 10
	end

	-- making the enemy move down
	for _,e in pairs(enemies_controller.enemies) do
		if e.y >= love.graphics.getHeight() then
			game_over = true
		end
		e.y = e.y + 1
	end

	-- Collision
	checkCollisions(enemies_controller.enemies, player.bullets)
end

-- function that draws things out
function love.draw()
	--love.graphics.scale(5)

	-- drawing the background
	love.graphics.draw(background_image)

	-- game over screen
	if game_over then
		love.graphics.print("Game Over Son!", 240, 250, 0, 3)
		return
	elseif game_win then
		love.graphics.print("You Won Son!!!", 240, 250, 0, 3)
	end

	-- 		paddle		    r    g    b
	love.graphics.setColor(255, 255, 255)

	-- creating the player
	love.graphics.draw(player.image, player.x, player.y, 0, 3)

	-- creating an enemy
	for _,e in pairs(enemies_controller.enemies) do
		love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 3)
	end

	-- creating the bullets
	love.graphics.setColor(255,255,255)
	for _,b in pairs(player.bullets) do
		love.graphics.rectangle("fill", b.x, b.y, 5, 5)
	end
end