module Slack
  extend self

  require 'net/http'

  TOKEN = "KXCueZCGFliMcvMwp5sZbmbm"
  SUBDOMAIN = "robd"

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
end