require_relative 'scraper'
require 'rufus-scheduler'
require 'yaml'

class Scheduler
    def self.init(urls, timer = '15m')
        scheduler = Rufus::Scheduler.new
        schedule_time = "#{(urls.length * 0.5) + timer.to_i}m"

        scheduler.every schedule_time do
            urls.each do |url|
                Scraper.process(url)
            end
        end

        scheduler.join
    end
end

# config = YAML.load_file('config.yml')
# URLS = config['config']['urls'] ||= []
# TIMER = config['config']['scheduler'] ||= '15m'

# # Run scheduler
# Scheduler.init(URLS, TIMER)
