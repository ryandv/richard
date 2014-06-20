module ApplicationHelper

  def format_as_minutes(seconds)
    return "" if seconds.nil?
    "#{(seconds / 60).ceil} minutes"
  end
end
