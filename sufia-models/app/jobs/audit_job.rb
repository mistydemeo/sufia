class AuditJob < ActiveFedoraPidBasedJob
  attr_accessor :pid, :datastream_id, :version_id

  PASS = 'Passing Audit Run'
  FAIL = 'Failing Audit Run'

  def initialize(pid, datastream_id, version_id)
    super(pid)
    @datastream_id = datastream_id
    @version_id = version_id
  end

  def queue_name
    :audit
  end

  def run
    return unless present?(generic_file)
    datastream = generic_file.datastreams[datastream_id]
    version =  datastream.versions.select { |v| v.versionID == version_id}.first
    log = run_audit(version)
    notify_user(log) unless log.pass == 1
  end

  private

  # send the user a message about the failing audit
  def notify_user(log)
    message = "The audit run at #{log.created_at} for #{log.pid}:#{log.dsid}:#{log.version} was #{log.pass == 1 ? 'passing' : 'failing'}."
    subject = log.pass == 1 ? PASS : FAIL
    job_user.send_message(user, message, subject)
  end

  # look up the user for sending the message to
  def user
    @user ||= begin
                login = generic_file.depositor
                user = User.find_by_user_key(generic_file.depositor)
                ActiveFedora::Base.logger.warn "User '#{login}' not found" unless user
                user
              end
  end

  def job_user
    User.audituser
  end

  def present?(gf)
    return true if gf && gf.datastreams[datastream_id]
    ActiveFedora::Base.logger.warn "No file/datastream for audit! (pid: #{pid}, dsid: #{datastream_id})"
    false
  end

  def run_audit(version)
    object.class.run_audit(version)
  end
end
