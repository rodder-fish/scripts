# frozen_string_literal: true

require_relative '../lib/database'

namespace :db do
  desc 'Create fishes table'
  task :create_fishes_table do
    Database.new.create_fishes_table
  end

  desc 'Load fish ids'
  task :load_fish_ids do
    Database.new.load_fish_ids('output/taiwan_fish_ids.csv')
  end
end
