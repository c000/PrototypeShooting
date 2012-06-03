class Item extends enchant.Sprite
	constructor: (@scene,x,y) ->
		enchant.Sprite.call this, 32, 32
		@image = game.assets['Images/player.png']
		@x = x
		@y = y
		@age = 0
		@itemNumber = 0
		this._element.style.zIndex = 3
		scene.addChild this
		@addEventListener 'enterframe', ->
			++@age
			@x += 12 * Math.cos (@age * Math.PI / 32)
			@y += 2
			if @y < -@height || @y > game.height + @height
				@remove()
			if @within player ,24
				player.item(@itemNumber)
				@remove()
		@key = items.length
		items[@key] = this
	remove: ->
		@scene.removeChild this
		delete items[@key]
		delete this
