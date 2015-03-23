crypto = require 'crypto'
_ = require 'underscore'

salt_default_length = 8
algo = 'sha256'

module.exports =
	algo:algo
	generateSalt:(length,callback)->
		if _.isUndefined callback
			callback = length
			length = salt_default_length
		cryptoSalt = ->
			crypto.randomBytes length,(ex, buf)->
				if ex?
					#most likely, entropy sources are drained so try again
					cryptoSalt() 
				else
					callback buf.toString('hex')
		cryptoSalt()
	generateSaltSync:(length)->
		length = length ? salt_default_length
		try
			return crypto.randomBytes(length).toString('hex')
		catch e
			return null

	hashPassword:(clear_password,salt)->
		return null if typeof clear_password != "string" or clear_password.length == 0
		shasum = crypto.createHash @algo
		shasum.update clear_password+salt
		return shasum.digest('hex')

	generateSaltAndHashPassword:(clear_password,cb)->
		@generateSalt 8,(salt)=>
			if salt == null
				cb null
			else
				cb {algo:algo,value:@hashPassword(clear_password,salt),salt:salt}

	generateSaltAndHashPasswordSync:(clear_password)->
		salt = @generateSaltSync 8
		if salt == null
			return null
		else
			return {
				algo:algo
				value:@hashPassword clear_password,salt
				salt:salt
			}