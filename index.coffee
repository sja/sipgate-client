Sipgate = require './lib/sipgate'
util = require 'util'
Q = require 'q'

successLogger = (res) -> 
	console.log util.inspect(res, colors:true, depth: null)

errorLogger = (reason) -> 
	console.error new Error(reason)

user = require './config'

# Callback variant
new Sipgate user, (sipgate) -> 
	sipgate.ownUriListGet().then(successLogger, errorLogger)


# Event variant
sg = new Sipgate(user)
sg.on 'ready', (sipgate) ->
	console.log "Sipgate API ready!"
	
	# Initiate a call
	sipgate.sessionInitiate(
		LocalUri:'sip:5555555e0@sipgate.de'	# 1st call this of my accounts and on pickup ...
		RemoteUri: 'sip:490311123123@sipgate.de' # 2nd call this number
	).delay(1000).then( (sessionId) -> # Waited a second before continue
		
		console.log "Initiated Call with SessionID '#{sessionId}'"
		
		# Now fetch and return the status code for the just initiated call
		sipgate.sessionStatusGet(sessionId)
	
	).then(successLogger, errorLogger)
	
	# Fetch my phonebook entries
	sipgate.phonebookListGet().then (results) ->
		
		# Extract EntryIDs from results:
		entryIds = results.map (result) -> result.EntryID
		sipgate.phonebookEntryGet(entryIds).then(successLogger, errorLogger)

