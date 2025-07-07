# frozen_string_literal: true

require_relative 'database'

module FishDB
  FISHDB_LIST_URL = 'https://fishdb.sinica.edu.tw/taxalist'
  FISHDB_DETAIL_URL = 'https://fishdb.sinica.edu.tw/taxon'
  DEFAULT_FISH_LIST_OUTPUT_FILENAME = 'output/taiwan_fish_ids.csv'

  class << self
    def download_fish_list(output = DEFAULT_FISH_LIST_OUTPUT_FILENAME)
      downloader = FishListDownloader.new(output, 0.5)
      downloader.download
    end

    def start_downloading_fish_details
      db = Database.new
      downloader = FishDetailsDownloader.new
      last_id = nil

      while (fish_base_id = db.next_pending_fish_base_id)
        break if last_id == fish_base_id

        last_id = fish_base_id

        puts "Downloading id: #{fish_base_id}"
        details = downloader.download(fish_base_id)
        db.save_fish_details(fish_base_id, details)
      end
    end
  end
end
