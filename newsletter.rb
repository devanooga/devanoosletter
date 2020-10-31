require 'slack-ruby-client'
require 'active_support/all'

class Newsletter
  attr_reader :client
  NEWSLETTER_CHANNEL = '#newsletter'

  def initialize(token: ENV.fetch('SLACK_TOKEN'))
    Slack.configure do |config|
      config.token = token
    end

    @client = Slack::Web::Client.new(token: token)
  end

  def email_body
    body = aggregate_submissions.map do |sub|
      "• #{sub[:title]}\n\t#{sub[:link]}\n\n\t#{word_wrap(sub[:text])}"
    end

    "#{email_topline}#{body.join("\n\n")}"
  end

  def email_topline
    week = Date.today.cweek
    "Devanooga Newsletter for Week #{week}\n\n"
  end

  def aggregate_submissions
    newsletter_messages.map do |message|
      submission = message['attachments'].first

      {
        link: submission['from_url'],
        title: submission['title'],
        text: submission['text']
      }
    end
  end

  def newsletter_messages
    messages = client.conversations_history(channel: NEWSLETTER_CHANNEL).messages
    from_past_week(from_reacji(messages))
  end

  def from_reacji(messages)
    messages.select { |msg| msg['username'] == 'Reacji Channeler' }
  end

  # Slack doesn't return normal timestamps, go read the docs on why we split
  # and need to turn it in to a normal timestamp
  def transform_timestamp(messages)
    messages.map do |message|
      time = message['ts'].split('.').first.to_i
      message['timestamp'] = Time.at(time)
      message
    end
  end

  def from_past_week(messages)
    messages = transform_timestamp(messages)
    messages.reject { |msg| msg['timestamp'] < 1.week.ago }
  end

  def word_wrap(text, line_width: 80, break_sequence: "\n")
    text.split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").rstrip : line
    end * break_sequence
  end
end

