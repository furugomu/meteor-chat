Rooms = new Meteor.Collection("rooms")
Messages = new Meteor.Collection("messages")

lpad = (value, length, ch) ->
  str = value.toString()
  if str.length >= length
    str
  else
    new Array(length-str.length+1).join(ch) + str

time = (value) ->
  t = new Date(value)
  if isNaN(t.getTime())
    ""
  else
    lpad(t.getHours(), 2, '0')+':'+lpad(t.getMinutes(), 2, '0')

if Meteor.is_client
  Meteor.subscribe("rooms")
  Meteor.autosubscribe ->
    roomId = Session.get("roomId")
    Meteor.subscribe("messages", roomId) if roomId

  Template.rooms.rooms = ->
    Rooms.find({}, {sort: {updatedAt: -1}})

  Template.rooms.events = 
    'submit': (e)->
      e.preventDefault()
      form = e.target
      roomId = Rooms.insert
        name: form.elements.name.value
      Session.set('roomId', roomId)
      form.reset()

  Template.room.selectedClassName = ->
    if Session.equals("roomId", this._id)
      'selected'
    else
      ''

  Template.room.updatedAt = ->
    time(this.updatedAt)

  Template.room.events =
    'click': ->
      Session.set('roomId', this._id)

  Template.chat.roomName = ->
    room = Rooms.findOne(Session.get('roomId'))
    room && room.name # room?.name

  Template.chat.messages = ->
    roomId = Session.get('roomId')
    Messages.find({roomId: roomId}, {sort: {createdAt: -1}})

  Template.message.createdAt = ->
    time(this.createdAt)

  Template.input.nick = ->
    Session.get('nick')

  Template.inputMessage.nick = ->
    Session.get('nick')

  Template.inputMessage.events =
    'submit': (e)->
      e.preventDefault()
      form = e.target
      Messages.insert
        roomId: Session.get('roomId')
        nick: Session.get('nick')
        text: form.elements.text.value
        createdAt: new Date()
      Rooms.update(Session.get('roomId'), $set: {updatedAt: new Date})
      form.reset()
      form.elements.text.focus()

  Template.inputNick.events =
    'submit': (e)->
      e.preventDefault()
      form = e.target
      Session.set('nick', form.elements.nick.value)

if Meteor.is_server
  Meteor.publish "rooms", ->
    Rooms.find()
  Meteor.publish "messages", (roomId)->
    Messages.find({roomId: roomId}, {sort: {createdAt: -1}, limit: 100})

  Meteor.setInterval ->
    t = new Date(Date.now() - 27*60*60*1000) # 27じかんまえ
    Rooms.remove({updatedAt: {$lt: t}})
  , 1000*60

  Meteor.startup ->
    if Rooms.find().count() == 0
      Rooms.insert(name: '島村卯月', updatedAt: new Date)
      Rooms.insert(name: '高森藍子', updatedAt: new Date)
