require 'telegram/bot'
require 'yaml'
require_relative 'scheduler'

# Read config from yaml file
config = YAML.load_file('config.yml')
TOKEN = config['token']
URLS = config['urls']
TIMER = config['scheduler']

# Run scheduler
Scheduler.init(URLS, TIMER)

# Register chat id into file
Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|
        case message.text
        when '/start'
            File.write('chat.txt', message.chat.id, mode: 'a')
            bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}.")
        else
        end
    end
end 
