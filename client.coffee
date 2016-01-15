Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Ui = require 'ui'
{tr} = require 'i18n'
Event = require 'event'
Form = require 'form'
Time = require 'time'
Server = require 'server'


funds = Obs.create(Db.shared.get("funds"))

exports.render = ->
	req0 = Page.state.get(0)
	if req0 is 'add'
		renderAdd()
		return
	if req0 is 'spend'
		renderSpend()
		return
	renderHome()

renderHome = !->
	#pot
	Dom.section !->
		Dom.div !->
			fund = Db.shared.get("funds")
			Dom.style Box: 'horizontal'
			Dom.div !->
				Dom.text tr("Funds")
				Dom.style
					Flex: true
					color: Plugin.colors().highlight
					marginTop: '1px'
			Dom.div !->
				Dom.style
					fontWeight: "bold"
					fontSize: '120%'
					textAlign: 'right'
				stylePositiveNegative(fund)
				Dom.text formatMoney(fund)
		Dom.style padding: '16px'

	Dom.div !->
		Dom.div !->
			Dom.style Box: 'horizontal'
			Dom.section !->
				Dom.text "+ Add"
				Dom.style
					color: Plugin.colors().highlight
					width: '50%'
					padding: '16px'
				Dom.onTap !->
					Page.nav ['add']
			Dom.section !->
				Dom.text "- Spend"
				Dom.style
					color: Plugin.colors().highlight
					width: '50%'
					padding: '16px'
				Dom.onTap !->
					Page.nav ['spend']


	if Db.shared.count("transactions").get() isnt 0
		Ui.list !->
		# Latest transactions
			Db.shared.iterate 'transactions', (tx) !->
				Ui.item !->
					Dom.style padding: '10px 8px 10px 8px'
					Dom.div !->
						Dom.style Box: 'horizontal', width: '100%'
						Dom.div !->
							Dom.style Flex: true
							Event.styleNew tx.get('created')
							Dom.text capitalizeFirst(tx.get('description'))
							Dom.style fontWeight: "bold"
						Dom.div !->
							Box: 'vertical'
							Dom.style textAlign: 'right', paddingLeft: '10px'
							Dom.div !->
								sum = tx.get('sum')
								stylePositiveNegative(sum)
								Dom.text formatMoney(sum)
			, (tx) -> -tx.key()

renderAdd = !->
	Page.setTitle "New transaction"

	Dom.div !->
		Dom.style
			margin: "-8px -8px 8px -8px"
			borderBottom: '2px solid #ccc'
			padding: '8px'
			backgroundColor: "#FFF"
		Dom.div !->
			Dom.style Box: 'top'
			Dom.div !->
				Dom.style Flex: true
				defaultValue = undefined
				Form.input
					name: 'description'
					value: defaultValue
					text: tr("Description")
		Dom.div !->
			Dom.style fontSize: '80%'
			# No amount entered	
			Form.condition (values) ->
				if (not (values.description?)) or values.description.length < 1
					return tr("Enter a description")

#adden
		Dom.div !->
				Dom.style marginTop: '20px'
			Dom.h2 tr("Add money")
		Dom.div !->
			Dom.style Box: 'horizontal'
			Dom.div !->
				currency = "€"
				if Db.shared.get("currency")
					currency = Db.shared.get("currency")
				Dom.text currency
				Dom.style
					margin: '-3px 5px 0 0'
					fontSize: '21px'
			inputField = undefined
			centField = undefined
			Dom.div !->
				Dom.style width: '80px', margin: '-20px 0 -20px 0'
				inputField = Form.input
					name: 'addinteger'
					type: 'number'
					text: '0'
					inScope: !->
						Dom.style textAlign: 'right'
			Dom.div !->
				Dom.style
					width: '10px'
					fontSize: '175%'
					padding: '12px 0 0 5px'
					margin: '-20px 0 -20px 0'
				Dom.text ","
			Dom.div !->
				Dom.style width: '50px', margin: '-20px 0 -20px 0'
				centField = Form.input
					name: 'adddecimal'
					type: 'number'
					text: '00'
		Dom.div !->
			Dom.style 
				fontSize: '80%'
			# No amount entered	
			Form.condition (values) ->
				if ((not (values.addinteger?)) or values.addinteger.length < 1) and ((not (values.adddecimal?)) or values.adddecimal.length < 1)
					return tr("Enter a sum")
		Form.setPageSubmit addsubmit, 0
addsubmit = (result) !->
	if result.adddecimal > 9
		sum = result.addinteger + result.adddecimal
	else if result.adddecimal > 0
		sum = result.addinteger + result.adddecimal*10
	else
		sum = result.addinteger*100	
	Server.call 'addtransaction', Plugin.userId(), result.description, sum
	Page.nav ['home']
	Modal.show ("you added: " + formatMoney(sum))

				
renderSpend = !->
	Page.setTitle "New transaction"

	Dom.div !->
		Dom.style
			margin: "-8px -8px 8px -8px"
			borderBottom: '2px solid #ccc'
			padding: '8px'
			backgroundColor: "#FFF"
		Dom.div !->
			Dom.style Box: 'top'
			Dom.div !->
				Dom.style Flex: true
				defaultValue = undefined
				Form.input
					name: 'description'
					value: defaultValue
					text: tr("Description")
		Dom.div !->
			Dom.style fontSize: '80%'
			# No amount entered	
			Form.condition (values) ->
				if (not (values.description?)) or values.description.length < 1
					return tr("Enter a description")

#spenden
		Dom.div !->
			Dom.style marginTop: '20px'
			Dom.h2 tr("Spend money")
		Dom.div !->
			Dom.style Box: 'horizontal'
			Dom.div !->
				currency = "€"
				if Db.shared.get("currency")
					currency = Db.shared.get("currency")
				Dom.text currency
				Dom.style
					margin: '-3px 5px 0 0'
					fontSize: '21px'
			inputField = undefined
			centField = undefined
			Dom.div !->
				Dom.style width: '80px', margin: '-20px 0 -20px 0'
				inputField = Form.input
					name: 'spendinteger'
					type: 'number'
					text: '0'
					inScope: !->
						Dom.style textAlign: 'right'
			Dom.div !->
				Dom.style
					width: '10px'
					fontSize: '175%'
					padding: '12px 0 0 5px'
					margin: '-20px 0 -20px 0'
				Dom.text ","
			Dom.div !->
				Dom.style width: '50px', margin: '-20px 0 -20px 0'
				centField = Form.input
					name: 'spenddecimal'
					type: 'number'
					text: '00'
		Dom.div !->
				Dom.style 
					fontSize: '80%'
				# No amount entered	
				Form.condition (values) ->
					if ((not (values.spendinteger?)) or values.spendinteger.length < 1) and ((not (values.spenddecimal?)) or values.spenddecimal.length < 1)
						return tr("Enter a sum")
		Form.setPageSubmit spendsubmit, 0

spendsubmit = (result) !->
	if result.spenddecimal > 9
		sum = result.spendinteger + result.spenddecimal
	else if result.spenddecimal > 0
		sum = result.spendinteger + result.spenddecimal*10
	else
		sum = result.spendinteger*100	
	Server.call 'spendtransaction', Plugin.userId(), result.description, sum
	Page.nav ['home']
	Modal.show ("you spent: " + formatMoney(sum))

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

stylePositiveNegative = (amount) !->
	if amount > 0
		Dom.style color: "#080"
	else if amount < 0
		Dom.style color: "#E41B1B"

capitalizeFirst = (string) ->
	return string.charAt(0).toUpperCase() + string.slice(1)
