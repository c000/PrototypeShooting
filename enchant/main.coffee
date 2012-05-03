`enchant()`
game = undefined
player = undefined
enemies = []
bgWaves = 64
bgMoves =
	x: 40 * Math.sin(Math.PI * 2 * i / bgWaves) for i in [0..bgWaves]
	y: 30 * Math.sin(Math.PI * 4 * i / bgWaves) for i in [0..bgWaves]

class yura
	@state = 0
	constructor: (i) -> @state = 8*i
	move: ->
		++@state
		mo =
			x : 8 * Math.cos @state * Math.PI / 8
			y : 8
		mo

BackGround = enchant.Class.create enchant.Sprite,
	initialize: (i) ->
		@i = i % bgWaves
		enchant.Sprite.call this, 640, 50
		@image = game.assets['Images/bg' + ((i%16)+1) + '.png']
		this._element.style.zIndex = 0
		@addEventListener 'enterframe', ->
			if game.frame % 3 == 0
				@i = (@i + 1) % bgWaves
				@x = bgMoves['x'][@i]
				@y = bgMoves['y'][@i] + i*20
		game.rootScene.addChild(this)

Player = enchant.Class.create enchant.Sprite,
	initialize: (x,y) ->
		enchant.Sprite.call(this, 32, 32)
		@image = game.assets['Images/player.png']
		@x = x - (@width / 2)
		@y = y - (@height / 2)
		@frame = [1]
		@moveSpeed = 6
		@shootSpan = 0
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
				new PlayerBullet(@x+@width/2, @y, 180)
				# new PlayerBullet(@x+@width/2, @y, 180-15)
				# new PlayerBullet(@x+@width/2, @y, 180+15)
				@shootSpan = 2
			@shootSpan--
		game.rootScene.addChild(this)

Enemy = enchant.Class.create enchant.Sprite,
	initialize: (x,y,moveFunc) ->
		enchant.Sprite.call this, 32, 32
		@image = game.assets['Images/enemy.png']
		@x = x
		@y = y
		@frame = [0]
		@moveFunc = moveFunc
		this._element.style.zIndex = 4
		@move = ->
			go = @moveFunc.move()
			@x += go.x
			@y += go.y
		@addEventListener 'enterframe', ->
			@move()
			if @y < -game.height || @y > 2*game.height || @x < -game.width || @x > 2*game.width
				@remove()
			if @within player, 16
				player.death()
		game.rootScene.addChild this
		@key = enemies.length
		enemies[@key] = this
	remove: ->
		game.rootScene.removeChild this
		delete enemies[this.key]
		delete this

Bullet = enchant.Class.create enchant.Sprite,
	initialize: (x,y,theta) ->
		enchant.Sprite.call(this,16,16)
		@image = game.assets['Images/player.png']
		@x = x - @width/2
		@y = y - @height/2
		@theta = Math.PI / 180 * theta
		@rotation = -theta
		@speed = 16
		@dx = Math.sin(@theta) * @speed
		@dy = Math.cos(@theta) * @speed
		@addEventListener 'enterframe', ->
			@x += @dx
			@y += @dy
			if @y < -game.height || @y > 2*game.height || @x < -game.width || @x > 2*game.width
				@remove()
		game.rootScene.addChild(this)
	remove: ->
		game.rootScene.removeChild(this)
		delete this

PlayerBullet = enchant.Class.create Bullet,
	initialize: (x,y,theta) ->
		Bullet.call(this, x, y, theta)
		@addEventListener 'enterframe', ->
			for key of enemies
				if enemies[key].intersect this
					@remove()
					enemies[key].remove()
					break

window.onload = ->
	game = new Game 640, 480
	game.fps = 60
	game.keybind(90, 'a')
	game.preload('Images/player.png', 'Images/enemy.png', 'Audio/enemyShoot.wav')
	for i in [1..16]
		game.preload('Images/bg'+i+'.png')

	game.onload = ->
		bgs = new BackGround(i) for i in [0..24]
		player = new Player(320,320)
		game.rootScene.backgroundColor = 'black'
		game.rootScene.addEventListener 'enterframe', ->
			if(game.frame % 10 == 0)
				new Enemy(120, 0, new yura 0)
				new Enemy(480, 0, new yura 1)

	game.start()
