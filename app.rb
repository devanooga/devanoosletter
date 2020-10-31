require 'sinatra'
require 'sinatra/json'
require 'json'
require 'faraday'

VERIFICATION_TOKEN = ENV.fetch('SLACK_VERIFICATION_TOKEN')

get '/' do
  'hello world'
end

post '/interact' do
  body = JSON.parse(params.dig('payload'))
  403 unless body.dig('token') == VERIFICATION_TOKEN

  action = detect_action(body.dig('actions').first.dig('text', 'text'))
  text = response_for(action)
  puts "Sending #{text} for action #{action}"

  reply(body.dig('response_url'), { replace_original: true, text: text })

  json({}, content_type: :json)
end

def response_for(action)
  if action == :approve
    'Newsletter approved. Sending now... 👍'
  else
    'Rescanning'
  end
end

def detect_action(text)
  return :approve if text.include?('Approve')
  return :rescan if text.include?('Rescan')
end

def reply(url, body)
  Faraday.post(url, body.to_json, 'Content-Type' => 'application/json')
end
