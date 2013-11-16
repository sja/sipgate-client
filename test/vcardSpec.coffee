###
Test vcard util function
###

vCard = require '../lib/vcard'
expect = require 'expect.js'

testData = "BEGIN:VCARD\r\nFN;quoted-printable:Charly Brown\r\nNOTE;quoted-printable:\r\nTEL;cell:+49123123123\r\nEND:VCARD"

describe "vCard util class", ->
	vcard = null

	describe "for one number", ->

		beforeEach ->
			vcard = vCard.parseVcard testData

		it "shold parse the name", ->
			expect(vcard.fn).to.be 'Charly Brown'

		it "shoud parse at least one phone number", ->
			expect(vcard.tel).to.be.an 'object'

		it "shoud parse the the cell phone number", ->
			expect(vcard.tel.cell).to.be '+49123123123'
