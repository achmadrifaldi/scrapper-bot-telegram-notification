require 'telegram/bot'
require 'yaml'

# Read config from yaml file
config = YAML.load_file('config.yml')
TOKEN = config['config']['token'] ||= ""

# Register chat id into file
Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|
        case message.text
        when '/start'
            File.write('chat.txt', "#{message.chat.id}\n", mode: 'a')
            bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}.")
        when '/info'
            bot.api.send_message(chat_id: message.chat.id, text: "Bot is running! use /start to start run")
        else
        end
    end
end 
