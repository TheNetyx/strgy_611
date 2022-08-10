class ApplicationController < ActionController::Base
  private
=begin
  def auth_teamid
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      teamid = Integer(params[:teamid])
      auth_for_acc_with_id(teamid, username, password) || auth_for_acc_with_id(0, username, password)
    end
  end

  def auth_admin
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      auth_for_acc_with_id(0, username, password)
    end
  end

  def auth_for_acc_with_id teamid, username, password
    username == Logins::USERNAMES[teamid] && password == Logins::PASSWORDS[teamid]
  end
=end

  def auth_teamid
    true
  end
  def auth_admin
    true
  end
  def auth_for_acc_with_id
    true
  end

  def self.add_item_log message
    i = ItemLog.new
    i[:message] = message
    i.save
  end
end
