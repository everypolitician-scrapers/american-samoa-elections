#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)

  current_district = ''
  noko.xpath('//h3[span[@id="Fono"]]/following-sibling::table[1]/tr[td]').each do |tr|
    tds = tr.css('td')
    current_district = tds.shift.text.tidy.split(/\s*[-–]\s*/,2) if tds.count == 5
    next unless tds.last.text.include? 'Elected'

    data = { 
      name: tds[0].text,
      area_id: current_district.first,
      area: current_district.last,
      party: "Independent",
      term: 2014,
      source: url,
    }
    ScraperWiki.save_sqlite([:name, :party, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/American_Samoan_general_election,_2014')
