Rooms = new Meteor.Collection("rooms");
Messages = new Meteor.Collection("messages");

if (Meteor.is_client) {
  Meteor.subscribe("rooms");
  Meteor.autosubscribe(function() {
    var roomId = Session.get("roomId");
    if (roomId) {
      Meteor.subscribe("messages", roomId);
    }
  });

  Template.rooms.rooms = function() {
    return Rooms.find({}, {sort: {name: 1}});
  };
  Template.rooms.events = {
    'submit': function(e) {
      e.preventDefault();
      var form = e.target;
      var roomId = Rooms.insert({
        name: form.elements.name.value
      });
      Session.set('roomId', roomId);
      form.reset();
    }
  }

  Template.room.selectedClassName = function() {
    return Session.equals("roomId", this._id) ? 'selected' : '';
  };
  Template.room.events = {
    'click': function() {
      Session.set('roomId', this._id);
    }
  };

  Template.chat.roomName = function() {
    var room = Rooms.findOne(Session.get('roomId'));
    return room && room.name;
  };

  Template.chat.messages = function() {
    var roomId = Session.get('roomId');
    return Messages.find({roomId: roomId}, {sort: {createdAt: -1}});
  };

  Template.input.nick = function() {
    return Session.get('nick');
  }
  Template.inputMessage.nick = function() {
    return Session.get('nick');
  }
  Template.inputMessage.events = {
    'submit': function(e) {
      e.preventDefault();
      var form = e.target;
      Messages.insert({
        roomId: Session.get('roomId'),
        nick: Session.get('nick'),
        text: form.elements.text.value,
        createdAt: new Date()
      });
      form.reset();
      form.elements.text.focus();
    }
  }

  Template.inputNick.events = {
    'submit': function(e) {
      e.preventDefault();
      var form = e.target;
      Session.set('nick', form.elements.nick.value);
    }
  };
}

if (Meteor.is_server) {
  Meteor.publish("rooms", function() {
    return Rooms.find();
  });
  Meteor.publish("messages", function(roomId) {
    return Messages.find({roomId: roomId}, {sort: {createdAt: -1}, limit: 100});
  });
  Meteor.startup(function () {
    if (Rooms.find().count() === 0) {
      Rooms.insert({name: '島村卯月'});
      Rooms.insert({name: '高森藍子'});
    }
  });
}
