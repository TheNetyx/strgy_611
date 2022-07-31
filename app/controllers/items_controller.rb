class ItemsController < ApplicationController
  before_action :auth_admin

  def use
    teamid = params[:teamid]
    item = Item.find_by identifier: params[:itemid]

    if item
      entry = ItemRequest.new
      entry[:team] = params[:teamid].to_i
      entry[:item] =  params[:itemid].to_i
      entry[:targetcell] = params[:targetcell]
      entry[:targetplayer] = params[:targetplayer].to_i
      entry[:processed] = false

      if self.class.check_fields entry, item[:fields]
        if params[:itemid].to_i == 2
          # instantly respawn using instant respawn
          p = Player.find params[:targetplayer]
          p.alive = true
          p.xpos = GridConf::TEAM_BASES[p.team - 1][:x]
          p.ypos = GridConf::TEAM_BASES[p.team - 1][:y]
          p.save
          self.class.add_item_log "team #{params[:teamid]} (#{TeamConf::NAMES[params[:teamid].to_i]}) used respawn on #{p.name}"
        else
          entry.save
          item["t#{teamid}".to_sym] -= 1
          item.save
        end
      else
        flash[:notice] = ["missing or invalid field(s)"]
      end
    else
      flash[:notice] = ["you do not own this item"]
    end
    redirect_back_or_to root_path
  end

  def add # can add negative quantities of items
    teamid = params[:teamid]
    entry = Item.find_by identifier: params[:itemid]

    entry["t#{teamid}".to_sym] += Integer(params[:quantity])
    entry["t#{teamid}".to_sym] = 0 if entry["t#{teamid}".to_sym] < 0

    entry.save

    redirect_back_or_to root_path
  end

  private
  def self.check_fields model, rules
    if rules & ItemConf::FieldsConstants::CELL > 0
      return false if !is_valid_space_wrapper model
    end
    if rules & ItemConf::FieldsConstants::TEAM > 0
      return false if (!is_valid_space_wrapper model) || (!GridConf::TEAM_BASES.include? coords_hash(model))
    end
    if rules & ItemConf::FieldsConstants::NOCP > 0
      return false if (!is_valid_space_wrapper model) || (GridConf::ALL_CP.include? coords_hash(model))
    end
    if (rules & ItemConf::FieldsConstants::ALIV > 0)
      return false if (!(p = Player.find model[:targetplayer].to_i)) || (p[:team] != model[:team] || !p[:alive])
    end
    if (rules & ItemConf::FieldsConstants::DEAD > 0)
      return false if (!(p = Player.find model[:targetplayer].to_i)) || (p[:team] != model[:team] || p[:alive])
    end
    true
  end

  def self.is_valid_space_wrapper model
    TheGrid.is_valid_space? coords_hash(model)
  end

  def self.coords_hash model
    split = model[:targetcell].split "-"
    {x: split[1].to_i, y: split[2].to_i}
  end

end
