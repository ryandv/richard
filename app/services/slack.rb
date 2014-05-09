module Slack
  extend self

  require 'net/http'
  require 'uri'

  TOKEN = "KXCueZCGFliMcvMwp5sZbmbm"
  SUBDOMAIN = "robd"

  TOKEN2 = "xoxp-2158087656-2158115218-2333605296-39dc5a"

  def notify_channel(status)
    url = "https://#{SUBDOMAIN}.slack.com/services/hooks/incoming-webhook?token=#{TOKEN}"
    message = "Gorgon is #{status}"
    payload = {'text' => message, 'username' => 'gorgon', 'icon_emoji' => ':ghost:'}.to_json

    request = Net::HTTP::Post.new(url)
    request.add_field "Content-Type", "application/json"
    request.body = payload

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)
    response.body
  end

  def notify(user)


    url = "https://#{SUBDOMAIN}.slack.com/services/hooks/incoming-webhook?token=#{TOKEN}"
    message = "I'm free"
    payload = {'text' => message, 'username' => 'gorgon', 'icon_emoji' => ':ghost:', 'channel' => '@robd'}.to_json

    request = Net::HTTP::Post.new(url)
    request.add_field "Content-Type", "application/json"
    request.body = payload

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)
    response.body
  end

  def get_slack_usernames
    uri = URI.parse("https://slack.com/api/users.list?token=xoxp-2158087656-2158115218-2333605296-39dc5a&#{TOKEN2}&pretty=1")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    users_json = JSON.parse(response.body)

    user_slacks = {}
    users_json["members"].each {|u| user_slacks[u["profile"]["email"]] = u["name"]}
    #puts user_slacks
  end
end