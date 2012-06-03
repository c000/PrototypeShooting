
`enchant()`
game = undefined
player = undefined
enemies = []
enemyKillCount = 0
items = []
bgWaves = 64
bgMoves =
	x: (60 * Math.sin(Math.PI * 2 * i / bgWaves) for i in [0..bgWaves])
	y: (50 * Math.sin(Math.PI * 4 * i / bgWaves) for i in [0..bgWaves])

class BackGround extends enchant.Sprite
	constructor: (@scene,i) ->
		@i = i % bgWaves
		enchant.Sprite.call this, 640, 60
		@image = game.assets['Images/bg' + ((i%16)+1) + '.png']
		this._element.style.zIndex = 0
		@addEventListener 'enterframe', ->
			if game.frame % 3 == 0
				@i = (@i + 1) % bgWaves
				@x = bgMoves['x'][@i]
				@y = bgMoves['y'][@i] + i*20
		scene.addChild(this)

class SoundLoader
	constructor: (@audio) ->
		@wave = @audio.clone()
	play: ->
		@wave.play()
		@wave = @audio.clone()

class YuraEnemy extends Enemy
	constructor: (scene,x,y) ->
		super scene,x,y
		@state = 0
	move: ->
		++@state
		@x += 8 * Math.cos @state * Math.PI / 8
		@y += 8

class StraightEnemy extends Enemy
	constructor: (scene,x,y) ->
		super scene,x,y
	move: ->
		@y += 4

class Bullet extends enchant.Sprite
	constructor: (@scene,x,y,theta) ->
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
		scene.addChild(this)
	remove: ->
		@scene.removeChild(this)
		delete this
	bang: ->
		new Bang(@scene, @x, @y)
		@remove()

class PlayerBullet extends Bullet
	constructor: (scene,x,y,theta) ->
		Bullet.call(this, scene, x, y, theta)
		@addEventListener 'enterframe', ->
			for key of enemies
				if enemies[key].intersect this
					@bang()
					enemies[key].remove()
					break

class Stage1 extends Scene
	constructor: ->
		super @
		enemies = []
		items = []
		new BackGround @, i for i in [0..24]
		player = new Player @, 320, 320
		@backgroundColor = 'black'
		@addEventListener 'enterframe', ->
			if(game.frame % 10 == 0)
				new YuraEnemy @, 120, 0
				new YuraEnemy @, 480, 0

window.onload = ->
	game = new Game 640, 480
	game.fps = 60
	game.keybind(90, 'a')
	game.preload('Images/player.png', 'Images/enemy.png', 'Images/bang.png')
	# game.preload('Audio/enemyShoot.wav')
	for i in [1..16]
		game.preload('Images/bg'+i+'.png')

	game.onload = ->
		game.rootScene.addEventListener 'enterframe', ->
			if game.input.a
				stage = new Stage1()
				game.pushScene stage

	game.start()

# vim: set fdm=indent:
