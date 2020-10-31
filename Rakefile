require_relative './newsletter'
require 'pry'

desc "Generate Newsletter"
task :prepare_newsletter do
  ace = 'U3ZR5UQD8'
  to = ENV['APPROVING_MODERATOR_ID'] || ace

  newsletter = Newsletter.new

  blocks = [{
  	"type": "actions",
		"elements": [
			{
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": "✅ Approve",
					"emoji": true
		  	}
			},
			{
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": "🔄 Rescan Submissions",
					"emoji": true
				}
		  }
	  ]
	}]

  message = <<-MSG
    Outgoing Newsletter
    ```
    #{newsletter.email_body}
    ```
  MSG

  binding.pry
  newsletter.client.chat_postMessage(channel: to, text: message)
  newsletter.client.chat_postMessage(channel: to, blocks: blocks.to_json)
end
