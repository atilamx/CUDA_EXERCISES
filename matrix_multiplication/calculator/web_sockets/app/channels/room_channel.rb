$LOAD_PATH << "/home/unix/workspace/CUDA_EXERCISES/matrix_multiplication/calculator/"
require 'nvidia'
class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    puts "RECEIVE BY SERVER #{data['receive']}"
    n = get_number_from_card(data['receive'].to_i)

    puts "Contacting Nvidia card returned value #{n}"
    ActionCable.server.broadcast "room_channel", message: "Calculated Valued from the card was #{n}"
  end
end
