class BatchUpdateJob
  include Hydra::PermissionsQuery
  include Sufia::Messages

  def queue_name
    :batch_update
  end

  attr_accessor :login, :title, :file_attributes, :batch_id, :visibility, :saved, :denied

  def initialize(login, params)
    @login = login
    @title = params[:title]
    @file_attributes = params[:generic_file]
    @visibility = params[:visibility]
    @batch_id = params[:id]
    @saved = []
    @denied = []
  end

  def saved
    @saved ||= []
  end

  def denied
    @denied ||= []
  end

  def batch
    @batch ||= Batch.find_or_create(@batch_id)
  end

  def user
    @user ||= User.find_by_user_key(@login)
  end

  def run
    batch.generic_files.each { |gf| update_file(gf, user) }
    batch.update_attributes({ status: ['Complete'] })
    send_user_notifications
  end

  def send_user_notifications
    if denied.empty?
      send_user_success_message(user, batch) unless saved.empty?
    else
      send_user_failure_message(user, batch)
    end
  end

  def authorized(user, gf)
    return true if user.can? :edit, gf
    ActiveFedora::Base.logger.error "User #{user.user_key} DENIED access to #{gf.pid}!"
    denied << gf
    false
  end

  def update_metadata(gf)
    gf.title = title[gf.pid] if title[gf.pid] rescue gf.label
    gf.attributes = file_attributes
    gf.visibility = visibility
  end

  def save_file(gf)
    Sufia::Utils.retry_rescue(3.times, RSolr::Error::Http) { gf.save! }
  rescue RSolr::Error::Http => error
    ActiveFedora::Base.logger.warn "BatchUpdateJob caught RSOLR error on #{gf.pid}: #{error.inspect}"
  end

  def update_file(gf, user)
    return unless authorized(user, gf)
    update_metadata(gf)
    save_file(gf)
    Sufia.queue.push(ContentUpdateEventJob.new(gf.pid, login))
    saved << gf
  end

  def send_user_success_message(user, batch)
    message = saved.count > 1 ? multiple_success(batch.noid, saved) : single_success(batch.noid, saved.first)
    User.batchuser.send_message(user, message, success_subject, sanitize_text = false)
  end

  def send_user_failure_message(user, batch)
    message = denied.count > 1 ? multiple_failure(batch.noid, denied) : single_failure(batch.noid, denied.first)
    User.batchuser.send_message(user, message, failure_subject, sanitize_text = false)
  end
end
