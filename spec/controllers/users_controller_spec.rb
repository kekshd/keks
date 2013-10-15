# encoding: utf-8

require 'spec_helper'

describe UsersController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  render_views

  it "updates user" do
    sign_in user
    post :update, id: user.id, user: { mail: "new_mail@example.com" }
    user.reload

    expect(user.mail).to eql("new_mail@example.com")
    expect(response).to redirect_to(edit_user_path(user))
    expect(flash[:success]).not_to be_nil
    expect(flash[:error]).to be_nil
  end

  it "prevents user from entering bogus mail" do
    sign_in user
    post :update, id: user.id, user: { mail: "invalid" }
    user.reload

    expect(user.mail).not_to eql("invalid")
    expect(response).to render_template("edit")
    expect(flash[:success]).to be_nil
  end

  describe "#enroll" do
    it "enables a user to enroll with a valid key" do
      sign_in user
      ek = EnrollmentKeys.names.first
      post :enroll, id: user.id, enrollment_key: ek
      expect(response).to redirect_to(edit_user_path(user))
      expect(flash[:success]).not_to be_nil
      expect(flash[:error]).to be_nil
      user.reload
      expect(user.enrollment_keys).to include(ek)
    end

    it "re-renders new page when something’s wrong" do
      # i.e. post misses password confirmation
      post :create, user: { nick: "Derpina", password: "123" }
      expect(flash[:success]).to be_nil
      expect(response).to render_template(:new)
    end

    it "re-renders edit page when enrolling with unknown key" do
      sign_in user
      ek = EnrollmentKeys.names.first + "derp"
      post :enroll, id: user.id, enrollment_key: ek
      expect(flash[:error]).not_to be_nil
      expect(response).to render_template(:edit)
      user.reload
      expect(user.enrollment_keys).to be_nil
    end

    it "re-renders edit page when enrolling with empty key" do
      sign_in user
      post :enroll, id: user.id
      expect(flash[:error]).not_to be_nil
      expect(response).to render_template(:edit)
      user.reload
      expect(user.enrollment_keys).to be_nil
    end

    it "warns user if already enrolled with that key" do
      sign_in user
      ek = EnrollmentKeys.names.first
      post :enroll, id: user.id, enrollment_key: ek
      post :enroll, id: user.id, enrollment_key: ek
      expect(flash[:warning]).not_to be_nil
      expect(response).to redirect_to(edit_user_path(user))
      user.reload
      expect(user.enrollment_keys).to include(ek)
      expect(user.enrollment_keys).not_to include("#{ek} #{ek}")
    end

    it "doesn’t allow user to enroll an other user" do
      sign_in user
      ek = EnrollmentKeys.names.first
      post :enroll, id: other_user.id, enrollment_key: ek
      expect(response).to redirect_to(root_path)
      user.reload
      expect(user.enrollment_keys).to be_nil
    end

    it "shows error when enrolling fails" do
      sign_in user
      User.stub(:find).and_return {
        user.stub(:save).and_return(false)
        user
      }
      ek = EnrollmentKeys.names.first
      post :enroll, id: user.id, enrollment_key: ek
      expect(flash[:error]).not_to be_nil
     expect(response).to render_template(:edit)
    end
  end

  it "renders the new template" do
    get :new
    response.should render_template("new")
  end

  it "renders the edit page for users with stats" do
    u = FactoryGirl.create(:user_with_stats)
    sign_in u
    get :edit, id: u.id
    expect(response).to render_template(:edit)
  end

  it "doesn’t show other user’s page" do
    sign_in user
    get :edit, id: other_user.id
    expect(response).to redirect_to(root_path)
  end

  it "renders user’s reviews for admins or reviewer" do
    sign_in admin
    get :reviews, id: reviewer.id
    expect(response).to render_template :reviews

    sign_in reviewer
    get :reviews, id: reviewer.id
    expect(response).to render_template :reviews
  end

  it "doesn’t show reviews to user" do
    sign_in user
    get :reviews, id: reviewer.id
    expect(response).to redirect_to(root_path)
  end


  it "does not render user index for users" do
    sign_in user
    get :index
    response.should_not render_template :index
  end

  it "renders user index for admins" do
    sign_in admin
    get :index
    response.should render_template :index
  end

  it "renders user’s history" do
    sign_in user
    get :history, id: user.id
    expect(response).to render_template :history
  end

  it "doesn’t render other_user’s history" do
    sign_in user
    get :history, id: other_user.id
    expect(response).to redirect_to(root_path)
  end

  it "shows an error if toggling admin/reviewer fails" do
    sign_in admin
    User.stub(:find).and_return {
      user.stub(:update_column).and_return(false)
      user
    }
    put :toggle_reviewer, id: user.id
    expect(response).to redirect_to(user_index_path)

    put :toggle_admin, id: user.id
    expect(response).to redirect_to(user_index_path)
  end


  it "admins may make someone reviewer" do
    sign_in admin
    put :toggle_reviewer, id: user.id
    response.should redirect_to(user_index_path)
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    user.reload
    user.reviewer?.should == true
    user.admin?.should == false
  end

  it "admins may make someone admin" do
    sign_in admin
    put :toggle_admin, id: other_user.id
    response.should redirect_to(user_index_path)
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    other_user.reload
    other_user.reviewer?.should == false
    other_user.admin?.should == true
  end

  it "redirects to user list if toggling invalid user" do
    sign_in admin
    put :toggle_admin, id: 123123123123 # hopefully doesn’t exist
    expect(response).to redirect_to(user_index_path)
    expect(flash[:success]).to be_nil
    expect(flash[:error]).not_to be_nil

    put :toggle_reviewer, id: 123123123123
    expect(response).to redirect_to(user_index_path)
    expect(flash[:success]).to be_nil
    expect(flash[:error]).not_to be_nil
  end

  it "prevents superadmins from being de-admin-ed" do
    admin.nick = SUPERADMIN.first
    admin.save
    sign_in admin
    put :toggle_admin, id: admin.id
    expect(response).to redirect_to(user_index_path)
    expect(flash[:success]).to be_nil
    expect(flash[:error]).not_to be_nil
  end
end
