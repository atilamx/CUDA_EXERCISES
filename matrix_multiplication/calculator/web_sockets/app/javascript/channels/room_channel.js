import consumer from "./consumer"

let a = consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to room channel")
	   //consumer.send({message: 'This is a cool chat app.'});
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
   console.log("Broadcast ${data}")
  }
});

window.hola=a
window.hola.received = function(data) {console.log(data)}

