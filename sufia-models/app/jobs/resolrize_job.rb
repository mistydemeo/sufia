class ResolrizeJob
  def queue_name
    :resolrize
  end

  def run
    if args_supported?
      ActiveFedora::Base.reindex_everything("pid~#{Sufia.config.id_namespace}:*")
    else
      ActiveFedora::Base.reindex_everything
    end
  end

  private

  def args_supported
    require 'active_fedora/version'
    active_fedora_version = Gem::Version.new(ActiveFedora::VERSION)
    minimum_feature_version = Gem::Version.new('6.4.4')
    active_fedora_version >= minimum_feature_version
  end
end
