require 'net/https'
require 'uri'
require 'tempfile'

class ImportUrlJob < ActiveFedoraPidBasedJob
  attr_reader :pid

  def queue_name
    :import_url
  end

  def run
    Tempfile.open(pid) do |f|
      path = copy_remote_file(f)
      attach_file(f, path)
    end
  end

  private

  def copy_remote_file(f)
    f.binmode
    download_from_url(f)
    f.rewind
    uri.path
  end

  # download file from url
  def download_from_url(f, uri=URI(generic_file.import_url))
    Net::HTTP.start(uri.host, uri.port, verify_mode: OpenSSL::SSL::VERIFY_NONE, use_ssl: uri.scheme == "https") do
      http.request_get(uri.request_uri) do |resp|
        resp.read_body { |segment| f.write(segment) }
      end
    end
  end

  # attach file to generic file
  def attach_file(f, path)
    if Sufia::GenericFile::Actor.new(generic_file, user).create_content(f, path, 'content')
      job_user.send_message(user, "The file (#{generic_file.content.label}) was successfully imported.", 'File Import')
    else
      job_user.send_message(user, generic_file.errors.full_messages.join(', '), 'File Import Error')
    end
  end

  def user
    @user ||= User.find_by_user_key(generic_file.depositor)
  end

  def job_user
    @job_user ||= User.batchuser
  end
end
