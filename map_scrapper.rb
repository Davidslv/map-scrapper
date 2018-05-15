require 'nokogiri'
require 'open-uri'

class MapScrapper
  def initialize
    @results = []
    @google = "https://www.google.co.uk/search?q="
  end

  def call
    puts 'processing ...'

    lines = File.readlines('streets.txt').size
    split = lines / 4

    top_list = File.readlines('streets.txt')[0..split]
    topp_list = File.readlines('streets.txt')[split..(split * 2)]
    bottom_list = File.readlines('streets.txt')[(split * 2) + 1..(split * 3)]
    bottomm_list = File.readlines('streets.txt')[(split * 3) + 1..-1]

    threads = []

    threads << Thread.new { process(top_list) }
    threads << Thread.new { process(topp_list) }
    threads << Thread.new { process(bottom_list) }
    threads << Thread.new { process(bottomm_list) }

    threads.each(&:join)

    puts '----- results -------'
    puts @results
  end

  private
    def process(list)
      list.each do |street|
        name = street.chomp

        doc = Nokogiri::HTML(open("#{@google}#{name.sub(" ","+")}"))
        text = doc.at('h3.r').children.last.children.map(&:text)

        puts "#{name}: #{text}"
        @results << "#{name}: #{text}"
      end
    end
end


MapScrapper.new.call
