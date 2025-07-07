# frozen_string_literal: true

require 'csv'
require 'sqlite3'
require 'json'

class Database
  DEFAULT_DATABASE_FILE = 'output/database.db'

  def initialize(database_path = DEFAULT_DATABASE_FILE)
    @db = SQLite3::Database.new(database_path)
  end

  def create_fishes_table
    sql = File.read('sql/fishes_table.sql')
    @db.execute_batch(sql)
  end

  def load_fish_ids(input)
    CSV.foreach(input, headers: false) do |row|
      fish_base_id = row[0].to_i

      @db.execute <<~SQL, [fish_base_id]
        INSERT OR IGNORE INTO fishes (fish_base_id)
        VALUES (?)
      SQL
    end
  end

  def next_pending_fish_base_id
    @db.get_first_value <<~SQL
      SELECT fish_base_id FROM fishes WHERE genus IS NULL LIMIT 1
    SQL
  end

  def save_fish_details(fish_base_id, details)
    columns = %i[
  genus species author year chinese_name chinese_alias
  chinese_synonyms english_synonyms attributes habitats waters
  description distribution size_info habitat_detail depth_info usage_info
]

    set_clause = columns.map { |col| "#{col} = ?" }.join(', ')
    values = columns.map do |key|
      val = details[key]
      val.is_a?(Array) ? JSON.dump(val) : val
    end
    values << fish_base_id

    sql = <<~SQL
      UPDATE fishes SET #{set_clause}
      WHERE fish_base_id = ?
    SQL

    @db.execute(sql, values)
  end
end
