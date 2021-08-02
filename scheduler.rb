require_relative 'scraper'
require 'rufus-scheduler'

class Scheduler
    def self.init(urls, timer = '15m')
        scheduler = Rufus::Scheduler.new

        scheduler.every timer do
            urls.each do |url|
                Scraper.process(url)
            end
        end

        scheduler.join
    end
end
