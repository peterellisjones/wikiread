require 'open-uri'
require 'nokogiri'
require 'lingua'
require 'json'
require 'redis'

task :add_articles, :count do |t, args|
  $redis = Redis.new(:host => 'localhost', :port => 6379)
  args.with_defaults(:count => '1')
  url = "http://en.wikipedia.org/wiki/Special:Random"
  args[:count].to_i.times do
    page = Nokogiri::HTML(open(url))
    results = {}
    results[:title] = page.css('h1#firstHeading').text
    results[:url] = page.css('div#p-views li#ca-view.selected a')[0]['href']
    content = ""
    page.css('div#mw-content-text p').each do |p| p
      content <<= p.text << '  '
    end
    # remove references
    content.gsub! /\[\d?\]/, ''
    # get readability stats
    report = Lingua::EN::Readability.new(content)
    [:num_words, :flesch, :kincaid, :fog].each do |method|
      results[method] = report.send method
    end
    puts "Checking: #{results[:title]}"
    # check sufficient words (200)
    if results[:num_words] >= 200
      # if doesn't yet exist, push
      unless $redis.sismember 'titles', results[:title]
        $redis.sadd 'titles', results[:title]
        $redis.sadd 'wikidata', results.to_json
        puts "-- added (##{$redis.scard('titles')})"
        puts results.inspect
      else
        puts "-- already exists"
      end
    else
      puts "-- too few words (#{results[:num_words]})"
    end
    sleep 2
  end
end