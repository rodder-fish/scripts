# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'httparty'
require 'nokogiri'

module FishDB
  class FishListDownloader
    def initialize(output, interval = 0.5)
      @output = output
      @interval = interval
    end

    def download
      FileUtils.mkdir_p(File.dirname(@output))
      download_list
    end

    private

    def download_list(page = 0, total = 0)
      url = "#{FISHDB_LIST_URL}?page=#{page}"
      response = HTTParty.get(url)
      doc = Nokogiri::HTML(response.body)

      rows = doc.css('.views-table tr')[1..] || []

      results = []
      rows.each do |row|
        a_tag = row.at_css('a[href*="/taxon/"]')
        scientific_name_tag = row.at_css('.views-field-solr-document')
        name_tag = row.at_css('.views-field-nothing')

        next unless a_tag && scientific_name_tag && name_tag

        id = a_tag['href'].split('/')[2].split('-').first
        scientific_name = scientific_name_tag.text.strip
        name = name_tag.text.strip

        results << [id, scientific_name, name]
      end

      total += results.size
      puts "Parsed page #{page}, total so far: #{total}"

      write_to_csv(results)

      if rows.any?
        sleep(@interval)
        download_list(page + 1, total)
      else
        puts "Done. The result has been written into #{@output}"
      end
    end

    def write_to_csv(results)
      CSV.open(@output, 'a') do |csv|
        results.each { |row| csv << row }
      end
    end
  end
end
