# spec/support/features/session_helpers.rb
module Features
  module SessionHelpers
    def sign_in(who = :user)
      logout
      user = who.is_a?(User) ? who : FactoryGirl.build(:user).tap { |u| u.save! }
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(page).not_to have_text 'Invalid email or password.'
    end

    def create_collection(title, description)
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      fill_in('Title', with: title)
      fill_in('Abstract or Summary', with: description)
      click_button("Create Collection")
      expect(page).to have_content 'Items in this Collection'
      expect(page).to have_content title
      expect(page).to have_content description
    end
  end
end
