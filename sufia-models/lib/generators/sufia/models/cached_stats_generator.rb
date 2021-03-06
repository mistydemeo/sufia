# -*- encoding : utf-8 -*-
require 'rails/generators'
require 'rails/generators/migration'

class Sufia::Models::CachedStatsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc """
This generator adds the ability to cache usage stats to your application:
 1. Creates several database migrations if they do not exist in /db/migrate
       """
  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(path)
    if @prev_migration_nr
      @prev_migration_nr += 1
    else
      if last_migration = Dir[File.join(path, '*.rb')].sort.last
        @prev_migration_nr = last_migration.sub(File.join(path, '/'), '').to_i + 1
      else
        @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      end
    end
    @prev_migration_nr.to_s
  end

  def banner
    say_status("warning", "ADDING STATS CACHING-RELATED SUFIA MODELS", :yellow)
  end

  # Setup the database migrations
  def copy_migrations
    # Can't get this any more DRY, because we need this order.
    [
      'create_file_view_stats.rb',
      'create_file_download_stats.rb'
    ].each do |file|
      better_migration_template file
    end
  end

  private

  def better_migration_template(file)
    begin
      migration_template "migrations/#{file}", "db/migrate/#{file}"
    rescue Rails::Generators::Error => e
      say_status("warning", e.message, :yellow)
    end
  end
end
