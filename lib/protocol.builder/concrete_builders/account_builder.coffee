_ = require 'underscore'
common =
	ver:1
	protocol:'account'
	dst:'ansamb'
	spl:'ansamb.account'
	dpl:'ansamb.account'
module.exports = 
	name:'account'
	api:
		getRequest:->
			message = _.extend
				method:"GET"
			,common
		registerRequest:(data)->
			aliases = {}
			if data.aliases
				_.each data.aliases,(alias)->
					aliases["#{alias.type}/#{alias.alias}"] = alias
			message = _.extend
				method:"REGISTER"
				data:
					aliases:aliases
					password:
						local:data.password.local
						ah:data.password.remote
					lang:data.lang
			,common
			message.data.firstname = data.firstname if data.firstname
			message.data.lastname = data.lastname if data.lastname
			return message
		generateCredentialRequest:(data)->
			return _.extend
				method:"GEN_CRED"
				data:
					service:data.service
			,common
		extendCredential:(data)->
			return _.extend
				method:"EXT_CRED"
				data:
					service:data.service
					username:data.username
					password:data.password
			,common
		accountReset:->
			return _.extend
				method:"RESET"
			,common
		registrationRetry:->
			return _.extend
				method:"RETRY"
			,common
		authRequest:(data)->
			return _.extend
				method:"AUTH"
				data:
					password:
						local:
							value:data.local
						ah:
							value:data.ah
			,common
		getUDID:->
			return _.extend
				method:"GET_UDID"
			,common
	schema:
		registerRequest:
			$schema:"http://json-schema.org/draft-04/schema#"
			type:"object"
			properties:
				data:
					type:"object"
					properties:
						aliases:
							type:"object"
							patternProperties:
								".+\/.+":
									type:"object"
									properties:
										alias:{type:"string"}
										type:{type:"string"}
									required:['alias','type']
						firstname:{type:"string"}
						lastname:{type:"string"}
						password:
							type:"object"
							properties:
								local:
									type:"object"
									properties:
										algo:{type:"string"}
										salt:{type:"string"}
										value:{type:"string"}
									require:["algo","salt","value"]
								ah:
									type:"object"
									properties:
										algo:{type:"string"}
										salt:{type:"string"}
										value:{type:"string"}
									require:["algo","salt","value"]
							required:["local","ah"]
						lang:{type:"string"}
					required:["aliases","password","firstname","lastname"]
			required:["data"]
		resendCodeRequest:
			$schema:"http://json-schema.org/draft-04/schema#"
			type:"object"
			properties:
				data:
					type:"object"
					properties:
						password:{type:"string"}
					required:["password"]
			required:["data"]
