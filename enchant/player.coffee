class Player extends enchant.Sprite
	constructor: (@scene,x,y) ->
		enchant.Sprite.call(this, 32, 32)
		@image = game.assets['Images/player.png']
		@x = x - (@width / 2)
		@y = y - (@height / 2)
		@frame = 1
		# @shootSound = new SoundLoader(game.assets['Audio/enemyShoot.wav'])
		@moveSpeed = 6
		@moveBound = (x, y) ->
			if x < 0
				x = 0
			if x > 640-@width
				x = 640-@width
			if y < 0
				y = 0
			if y > 480-@height
				y = 480-@height
			return {
				x: x
				y: y
			}
		@shootSpan = 0
		@shootType = 0
		@addEventListener 'enterframe', (e) ->
			if game.input.right
				@x += @moveSpeed
			if game.input.left
				@x -= @moveSpeed
			if game.input.up
				@y -= @moveSpeed
			if game.input.down
				@y += @moveSpeed
			if game.input.a && @shootSpan <= 0
				new PlayerBullet(@scene, @x+@width/2, @y, 180)
				for i in [0..@shootType]
					new PlayerBullet(@scene, @x+@width/2, @y, 180 - 15 * i)
					new PlayerBullet(@scene, @x+@width/2, @y, 180 + 15 * i)
				# @shootSound.play()
				@shootSpan = 4
			@shootSpan--
			newPos = @moveBound(@x, @y)
			@x = newPos.x
			@y = newPos.y
		scene.addChild(this)
	item: (i) ->
		switch i
			when 0 then ++@shootType
	death: ->
		game.popScene()
