require 'kimurai'
require 'telegram/bot'
require 'json'
require 'yaml'
require 'date'

class Scraper < Kimurai::Base
  @name = "scraper"
  @engine = :selenium_chrome

  # Custom config to skip cloudflare
  @config = {
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36",
    before_request: { delay: 4..7 }
  }

  def self.process(url)
    @start_urls = [url]
    self.crawl!
  end

  def parse(response, url:, data: {})
    # Wait for content to be full rendered
    sleep 5

    response = browser.current_response

    message = ""

    # Only get first row
    [1].each do |position|
      # Parse data from response
      payload = {
        tlm: {
          token_amount: response.xpath("//table[@id='tokenTable']/tbody/div/div[@class='item'][1]/div[@class='content']/div[@class='description']/span[@class='token-amount']").text, 
          description:  response.xpath("//table[@id='tokenTable']/tbody/div/div[@class='item'][1]").text
        },
        tx: response.xpath("//div[@class='actions-table']/table/tbody/tr[#{position}]/td[1]").text,
        date: response.xpath("//div[@class='actions-table']/table/tbody/tr[#{position}]/td[2]").text,
        actions: response.xpath("//div[@class='actions-table']/table/tbody/tr[#{position}]/td[3]").text,
        data: response.xpath("//div[@class='actions-table']/table/tbody/tr[#{position}]/td[4]").text
      }

      dateParse = DateTime.parse(payload[:date]).to_time
      ctime = DateTime.now.to_time
      diffTime = Time.at((ctime - dateParse)).strftime("%R:%S")

      # Message content

      text = "*CHAIN DATA:* \n ```#{payload[:tlm][:token_amount]} #{payload[:tlm][:description]}```\n"
      text += "=========================\n"
      text += "*SERVER TIME:* #{ctime.strftime("%b %d, %Y  %I:%M:%S %p")}\n"
      text += "*DATA TIME:* #{payload[:date]}\n"
      text += "*DIFF TIME:* #{diffTime}\n"
      text += "*ACTIONS:* #{payload[:actions]}\n"
      text += "*DATA:* ```#{payload[:data]}```\n"
      # text += "=========================\n"

      message += text
    end

    # Read config from yaml file
    config = YAML.load_file('config.yml')

    # Send notification to telegram channel
    Telegram::Bot::Client.run(config['config']['token']) do |bot|
      File.foreach('chat.txt').with_index do |line, line_num|
        bot.api.send_message(chat_id: line, text: message, parse_mode: 'Markdown')
      end
    end
  end
end
