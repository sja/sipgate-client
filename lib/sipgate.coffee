'use strict'

util 			= require 'util'
xmlrpc 			= require 'xmlrpc'
Q 				= require 'q'
{EventEmitter} 	= require 'events'
vCard 			= require './vcard'

identity = [
	ClientName: 	'node-sipgate-client'
	ClientVersion:	'0.0.1'
	ClientVendor:	'SebastianJanzen'
]

#Q.longStackSupport = true

module.exports = class Sipgate extends EventEmitter

	# Initialize XMLRPC module with options and credentials
	# After that, send API server our identification
	# If callback was set, call it after successful identification
	constructor: (auth, callback) ->
		@config = 
			host: "samurai.sipgate.net"
			port: 443
			path: "/RPC2"
			basic_auth: auth
		@client = new xmlrpc.createSecureClient(@config)
		@methodCall = Q.nbind(@client.methodCall, @client)
		identify = @clientIdentify().catch(@_errorHandler)
		if typeof callback is 'function'
			identify.then(callback)

	# Print errors on stderr and throw exception
	_errorHandler: (reason) ->
		console.error reason
		throw new Error reason

	# Determine response's status code to be 200.
	# Otherwise, reject promise and print server error message.
	_validateResponse: (response) ->
		if response.StatusCode isnt 200
			return Q.reject "The Sipgate API returned #{response.StatusCode}: #{response.StatusString}"
		response

	# Wrap @methodCall to ensure that all responses are verified.
	# On successful call, unwrap response and resolve promise with this value
	_methodCallSafe: ({method, prefix, responseName, args}) ->
		args ?= null
		prefix ?= 'samurai'
		unless method
			return Q.reject "Method was not set!"
		@methodCall("#{prefix}.#{method}", args)
		.then(@_validateResponse)
		.then (response) ->
			if typeof response[responseName] is 'undefined'
				return Q.reject "Response does not contain attribute '#{responseName}'"
			response[responseName]

	listMethods: ->
		@_methodCallSafe 
			method:'listMethods'
			prefix: 'system'
			responseName: 'listMethods'

	clientIdentify: ->
		@methodCall("samurai.ClientIdentify", identity)
		.then(@_validateResponse)
		.then (response) =>
			if response.StatusCode isnt 200
				return Q.reject "Couldn't identify to server!"
			@emit "ready", @, response
			return @

	phonebookListGet: ->
		@_methodCallSafe 
			method:'PhonebookListGet'
			responseName: 'PhonebookList'

	phonebookEntryGet: (entryIds) ->
		entryIds = [entryIds] unless Array.isArray entryIds
		args = EntryIDList: entryIds
		@_methodCallSafe(method: 'PhonebookEntryGet', args: [args])
		.then (response) => 
			response.EntryList.forEach (entry, idx, array) =>
				array[idx].Entry = vCard.parseVcard(entry.Entry)
			response.EntryList

	sessionInitiate: (options) ->
		options.TOS ?= 'voice'
		unless options.LocalUri and options.RemoteUri
			return Q.reject "Mandatory options: 'LocalUri' and 'RemoteUri'"
		@_methodCallSafe
			method: "SessionInitiate"
			args: [options]
			responseName: "SessionID"

	ownUriListGet: ->
		@_methodCallSafe
			method: "OwnUriListGet"
			responseName: "OwnUriList"

	sessionStatusGet: (sessionId) ->
		@_methodCallSafe
			method: "SessionStatusGet"
			args: [SessionID: sessionId]
			responseName: "StatusCode"

	balanceGet: ->
		@_methodCallSafe
			method: "BalanceGet"
			responseName: "CurrentBalance"
