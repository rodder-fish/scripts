# frozen_string_literal: true

require_relative 'fish_db/fish_list_downloader'

module FishDb
  FISHDB_LIST_URL = 'https://fishdb.sinica.edu.tw/taxalist'
  DEFAULT_FISH_LIST_OUTPUT_FILENAME = 'output/taiwan_fish_ids.csv'

  class << self
    def download_fish_list(output = DEFAULT_FISH_LIST_OUTPUT_FILENAME)
      downloader = FishListDownloader.new(output, 0.5)
      downloader.download
    end
  end
end
