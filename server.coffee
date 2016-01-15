Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = ->
	# set funds
	Db.shared.set 'funds', 0

exports.onUpgrade = ->
	Db.shared.set 'funds', 0
	Db.shared.set 'transactions', null
	Db.shared.set 'maxId', null

exports.client_addtransaction = (userid, descr, s) !->
	Db.shared.modify 'funds', (v) -> v + s*1
	id = Db.shared.incr 'maxId'
	Db.shared.set 'transactions', id, {creator: userid, description: descr, sum: s}
	Event.create
		text: Plugin.userName(userid) + " added " + formatMoney(s)
		sender: userid

exports.client_spendtransaction = (userid, descr, s) !->
	Db.shared.modify 'funds', (v) -> v - s*1
	id = Db.shared.incr 'maxId'
	Db.shared.set 'transactions', id, {creator:userid, description: descr, sum: -s}
	Event.create
		text: Plugin.userName(userid) + " spend " + formatMoney(s)
		sender: userid
		
formatMoney = (amount) ->
	amount = Math.round(amount)
	currency = "€"
	if Db.shared.get("currency")
		currency = Db.shared.get("currency")
	string = amount/100
	if amount%100 is 0
		string +=".00"
	else if amount%10 is 0
		string += "0"
	return currency+(string)