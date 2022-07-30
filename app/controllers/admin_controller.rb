class AdminController < ApplicationController
  before_action :auth_admin

  def index # this is unused now.
    redirect_to manage_path
  end

  def manage
    if Round.all.first == nil then
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
  def get_conflicts # TODO: unretardify this.
    conflicts = []
    locations = []
    Player.where("alive = true").order(:team).order(:name).each do |tp|
      locations.push({player: tp, locid: tp.xpos * 9 + tp.ypos})
    end
    while locations.length > 0
      sameloc = [locations[0][:player]]
      locid = locations[0][:locid]
      todel = []

      (1..(locations.length - 1)).each do |i|
        if locations[i][:locid] == locid
          sameloc.push locations[i][:player]
          # dont delete the players yet to avoid messing with i and array indices
        end
      end

      if sameloc.length > 1
        t = sameloc[1].team
        conflicts.push({combatants: sameloc}) unless sameloc.all?{|i| i.team == t}
      end
      locations.each do |loc|
        if loc[:locid] == locid
          todel.push loc
        end
      end
      todel.each do |item|
        locations.delete item
      end
    end
    conflicts
  end
end
