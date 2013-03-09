# encoding: utf-8

require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }
end
