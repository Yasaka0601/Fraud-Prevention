class RoomsController < ApplicationController
  def room; end

  def new
    @room = Room.new
  end
end