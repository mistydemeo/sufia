class FileViewStat < ActiveRecord::Base
  extend Sufia::FileStatUtils

  def to_flot
    [ self.class.convert_date(date), views ]
  end

  def self.statistics file_id, start_date
    combined_stats file_id, start_date, :views, :pageviews
  end

  # Sufia::Download is sent to Sufia::Analytics.profile as #sufia__download
  # see Legato::ProfileMethods.method_name_from_klass
  def self.ga_statistics start_date, file_id
    path = Sufia::Engine.routes.url_helpers.generic_file_path(Sufia::Noid.noidify(file_id))
    Sufia::Analytics.profile.sufia__pageview(sort: 'date', start_date: start_date).for_path(path)
  end
end
