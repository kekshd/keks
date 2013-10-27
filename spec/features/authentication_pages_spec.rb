# encoding: utf-8

require 'spec_helper'

describe "Authentication" do
  let(:user) { FactoryGirl.create(:user) }
  let(:wrong_user) { FactoryGirl.create(:user, mail: "wrong@example.com") }
  let(:non_admin) { FactoryGirl.create(:user) }

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h2',    text: 'Einloggen') }
    # i.e. title not complete
    it { should_not have_selector('title', text: /^KeKs – $/) }
  end

  describe "signin" do
    self.use_transactional_fixtures = false

    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Einloggen" }

      it { should have_title('KeKs – Einloggen') }
      it { should have_selector('.alert-error', text: 'ungültig') }

      describe "after visiting another page" do
        before { click_link "Startseite" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information permanently" do
      before do
        fill_in "Nick",     with: user.nick
        fill_in "Passwort", with: user.password
        check "Dauerhaft?"
        click_button "Einloggen"
      end

      it { should have_link('Ausloggen', href: signout_path) }
      it "has set remember cookie" do
        expect(page.driver.cookies.find("remember_token").to_s).to \
          include(user.remember_token, "2033")
      end
    end

    describe "with valid information" do
      before do
        fill_in "Nick",     with: user.nick
        fill_in "Passwort", with: user.password
        click_button "Einloggen"
      end

      it { should have_title('Fragen beantworten') }

      it { should have_link('Profil',    href: edit_user_path(user)) }
      it { should have_link('Gemerkte',  href: starred_path(user)) }
      it { should have_link('Ausloggen', href: signout_path) }
      it { should_not have_link('Admin',     href: admin_overview_path) }
      it { should_not have_link('Einloggen', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Ausloggen" }
        it { should have_link('Einloggen') }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Nick",     with: user.nick
          fill_in "Passwort", with: user.password
          click_button "Einloggen"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_title('Dein Profil')
          end

          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Nick",     with: user.nick
              fill_in "Passwort", with: user.password
              click_button "Einloggen"
            end

            it "should render the default (profile) page" do
              page.should have_title('KeKs – Fragen beantworten')
            end
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title("Einloggen") }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_url) }
        end

      end

    end

    describe "as wrong user" do
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title('Dein Profil') }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_url) }
      end
    end
  end
end
