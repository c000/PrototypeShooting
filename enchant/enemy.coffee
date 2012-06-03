class Enemy extends enchant.Sprite
	constructor: (@scene,x,y) ->
		enchant.Sprite.call this, 32, 32
		@image = game.assets['Images/enemy.png']
		@x = x
		@y = y
		this._element.style.zIndex = 4
		@addEventListener 'enterframe', ->
			@move()
			++@frame
			if @y < -game.height || @y > 2*game.height || @x < -game.width || @x > 2*game.width
				@remove()
			if @within player, 16
				player.death()
		scene.addChild this
		@key = enemies.length
		enemies[@key] = this
	remove: ->
		++enemyKillCount
		if enemyKillCount % 16 == 0
			new Item @scene, @x, @y
		@scene.removeChild this
		delete enemies[@key]
		delete this
	move: ->
		console.log "Super move"
