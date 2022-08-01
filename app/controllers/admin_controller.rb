class AdminController < ApplicationController
  before_action :auth_admin

  def index # this is unused now.
    redirect_to manage_path
  end

  def manage
    unless Round.first then
      redirect_to start_game_path
    end

    @new_player = Player.new
    @players = Player.order(:team).order(:name)
    @round = Round.all.first

    @items = []
    Item.order(:name).each do |item|
      @items.push({
        name: item.name,
        count: [
          item.t1,
          item.t2,
          item.t3,
          item.t4,
          item.t5,
          item.t6,
          item.t7,
          item.t8
        ],
        id: item.identifier
      })
    end
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
    @conflicts = get_conflicts

    @logs = ItemLog.all
  end


  # only the essentials for running a game:
  # > game map
  # > conflict detection and resolution
  # thats it.
  def manage_simple
    @round = Round.all.first
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

    @conflicts = get_conflicts

    @logs = ItemLog.all
  end

  private
  def get_conflicts
    conflicts = []
    locations = []
    repeats = nil

    Player.where("alive = true").order(:team).each do |tp|
      locations.push({x: tp.xpos, y: tp.ypos})
    end

    repeats = locations.select{ |i| locations.count(i) > 1 }.uniq
    repeats.each do |r|
      occupants = Player.where("alive=true AND xpos = ? AND ypos = ?", r[:x], r[:y]).order(:team)
      t = occupants[0].team
      conflicts.push({combatants: occupants}) unless occupants.all?{|i| i.team == t}
    end

    conflicts.sort_by { |c| c[:combatants][0][:ypos] * GridConf::GRIDSIZE + c[:combatants][0][:xpos] }
  end
end
