# frozen_string_literal: true

require_relative '../lib/fish_db'

namespace :fish do
  desc 'Scrape Taiwan fish IDs and scientific names'
  task :download_list do
    FishDb.download_fish_list
  end
end
