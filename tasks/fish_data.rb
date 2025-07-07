# frozen_string_literal: true

require_relative '../lib/fish_db'
require_relative '../lib/fish_db/fish_details_downloader'

namespace :fish do
  desc 'Scrape Taiwan fish IDs and scientific names'
  task :download_list do
    FishDB.download_fish_list
  end

  desc 'Start downloading pending fish details'
  task :download_details do
    FishDB.start_downloading_fish_details
  end
end
