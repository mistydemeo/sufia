# This tests attempts to upload a file to Sufia mimicking the steps
# the users follows in the browser.
#
# This tests works in Sufia with Fedora 3 but fails with Fedora 4.
#
# The error seems to be somewhere in ldp.create. The error reported
# in this test is a bit misleading since it is reporting a timeout 
# but I the underlying problem seems to be how we push the data 
# to Fedora.
#
require 'spec_helper'

include Selectors::Dashboard

def debug_message message
  puts "\tDEBUG >> #{message}"
end


def wait_for_page (redirect_url)
  Timeout.timeout(30) do
    debug_message "#{current_path}, #{redirect_url}"
    loop until current_path == redirect_url
  end
end


def upload_generic_file filename
  # HTTP GET /files/new
  full_path = "#{fixture_path}/#{filename}"
  debug_message "upload_generic_file, #{full_path}"
  visit '/files/new'
  check 'terms_of_service'
  attach_file 'files[]', full_path
  redirect_url = find("#redirect-loc", visible:false).text
  debug_message "about to push upload button"
  
  # start upload
  click_button 'main_upload_start'
  debug_message "waiting for redirect"

  # HTTP GET /batches/batch-id/edit
  wait_for_page redirect_url
  debug_message "redirected, validating metadata page"
  fill_in 'generic_file_tag', with: filename + '_tag'
  fill_in 'generic_file_creator', with: filename + '_creator'
  select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
  debug_message "About to push submit button"

  # save button
  click_on 'upload_submit'
end


describe 'Generic file upload:' do
  let(:user)          { FactoryGirl.find_or_create(:archivist) }
  let(:filename)      { 'small_file.txt' }
  let(:batch)         { ['small_file.txt', 'small_file.txt'] }
  let(:file)          { find_file_by_title "small_file.txt" }

  before do
    sign_in user
  end

  context 'when logged in' do
    it 'upload a single file' do
      upload_generic_file filename
      expect(page).to have_css '#documents'
      expect(page).to have_content filename
    end
  end
end