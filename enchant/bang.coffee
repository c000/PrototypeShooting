class Bang extends enchant.Sprite
	constructor: (@scene, x, y) ->
		enchant.Sprite.call this, 128, 128
		@image = game.assets['Images/bang.png']
		@x = x - (@width / 2)
		@y = y - (@height / 2)
		this._element.style.zIndex = 1
		@addEventListener 'enterframe', ->
			if game.frame % 2 == 0
				++@frame
			if @frame > 12
				@remove()
		scene.addChild this
	remove: ->
		@scene.removeChild @
		delete @
