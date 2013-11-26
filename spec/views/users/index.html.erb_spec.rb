# encoding: utf-8

require "spec_helper"

describe "users/index.html.erb" do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:user) { FactoryGirl.create(:user) }


  describe "manually resolved links are correct" do
    before(:each) do
      view.stub(:current_user).and_return(admin)
      assign(:admins, [admin, reviewer])
      assign(:users, [user])
      assign(:reviews_count, [])
      render
    end

    it "has correct toggle links for users" do
      expect(rendered).to have_link("zum Reviewer machen", href: user_toggle_reviewer_path(user.id))
      expect(rendered).to have_link("zum Admin machen", href: user_toggle_admin_path(user.id))
    end

    it "has correct toggle links for admins/reviewers" do
      expect(rendered).to have_link("Reviewer-Status umschalten", href: user_toggle_reviewer_path(admin.id))
      expect(rendered).to have_link("Admin-Status umschalten", href: user_toggle_admin_path(reviewer.id))
    end
  end
end
