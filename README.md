#sipgate-client


Sipgate client to access their XMLRPC-API, which is for free for every Customer.

The method names are in lean to the XMLRPC-Methods, which are documented in [sipgate api documentation](http://www.sipgate.de/basic/api). If you're already familiar with this, you'll feel home.

Waring: Currently I only implemented the methods I needed. Feel free to contribute.

#Methods
##`Sipgate({user: '', pass: ''}, cb)`
Create API-object. The first options object contains properties `user` and `pass`. These are the credentials you use to log in to the sipgate webinterface. The callback cb is optional. See example below or `index.coffee`.

##`phonebookListGet()`
Fetch a list of phonebook ids and their hash. With those ids you can fetch the entries details with `phonebookEntryGet`. You can use the hash to determine changes to the phonebook entries rather than fetching the details. No parameters needed.

##`phonebookEntryGet([<ID>, <ID>, ...])`
Fetch a list of phonebook entries. The IDs are Phonebook-Entry-IDs. See `phonebookListGet` for how to get those IDs.

##`sessionInitiate({LocalUri: '<uri>', RemoteUri: '<uri>'})`
Initiate a new call from one of your devices to a phone number. The parameters' Uris are in form of `sip:<E164-Number>@sipgate.de`. See `index.coffee` for an example.
You can add a property `TOS` and `Content` to send SMS or `Schedule` to plan a call initiated later. See Sipgate Docs for more info on that.
The result of an sessionInitiate is a `sessionId`.

##ownUriListGet()
Some information of your account. See example output below. This is interesting to get your own Uris which you can use to `sessionInitiate`.

##`sessionStatusGet(sessionId)`
Fetch status code of an initiated session. The values are something like HTTP status codes, but see the docs for more details.

##`balanceGet()`
Fetch the user's account balance.

# Example
```coffeescript

Sipgate = require './lib/sipgate'
util = require 'util'

successLogger = (res) -> 
	console.log util.inspect(res, colors:true, depth: null)

errorLogger = (reason) -> 
	console.error new Error(reason)

user = 
	user: 'sebastian'
	pass: 'secretPW!'

# Callback variant
new Sipgate user, (sipgate) -> 
	sipgate.ownUriListGet().then(successLogger, errorLogger)


# Event variant
sg = new Sipgate(user)
sg.on 'ready', (sipgate) ->
	console.log "Sipgate API ready!"
	sipgate.phonebookListGet().then (results) ->
		
		# Extract EntryIDs from results:
		entryIds = results.map (result) -> result.EntryID

		sipgate.phonebookEntryGet(entryIds).then(successLogger, errorLogger)

```
##Results
###First Output:
```javascript
	[ { UriAlias: '',
	    E164Out: '49123123',
	    DefaultUri: true,
	    E164In: 
	     [ '4922155555555',
	       '4922155555556',
	       '4922155555557',
	       '4922155555558' ],
	    TOS: [ 'voice' ],
	    SipUri: 'sip:5555555e0@sipgate.de' },
	  { UriAlias: 'User A',
	    E164Out: '4922155555555',
	    DefaultUri: false,
	    E164In: [ '492217777777' ],
	    TOS: [ 'voice' ],
	    SipUri: 'sip:5555555e1@sipgate.de' },
	  { UriAlias: 'User B',
	    E164Out: '4922155555556',
	    DefaultUri: false,
	    E164In: [ '492216666666' ],
	    TOS: [ 'voice' ],
	    SipUri: 'sip:5555555e2@sipgate.de' },
	  { UriAlias: '',
	    E164Out: '4922155555557',
	    DefaultUri: false,
	    E164In: [ '4922188888888' ],
	    TOS: [ 'fax' ],
	    SipUri: 'sip:5555555e9@sipgate.de' } ]
```

###Second Output
```javascript
	Sipgate API ready!
	[ { EntryID: '18332',
	    Entry: { fn: 'Torsten Ungemach', tel: { voice: '+49123123' } },
	    EntryHash: 'a4kVLjbho2OdzCayG/CLTA' },
	  { EntryID: '81651',
	    Entry: { fn: 'Sven Bleistift', tel: { cell: '+49123123' } },
	    EntryHash: 'NYkP5volFclaxMbl5v9UHA' },
	  { EntryID: '83513',
	    Entry: { fn: 'Anne Ranzen', tel: { cell: '+49123123' } },
	    EntryHash: 'oCg2BkFNUTNP8GAoqlO2Ng' } ]
```


# TODO
This npm could be improved by using the `listMethods` and `methodSignature` methods to dynamically build the sipgate class' methods.