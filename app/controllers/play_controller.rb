class PlayController < ApplicationController
  before_action :auth_teamid
  def index
    @teamid = params[:teamid]
    @grid_conf = GridConf::GRID_CONF
    @round = Round.first
    @scores = [
      @round.t1s,
      @round.t2s,
      @round.t3s,
      @round.t4s,
      @round.t5s,
      @round.t6s,
      @round.t7s,
      @round.t8s,
    ]
    @items = Item.all
  end
end
