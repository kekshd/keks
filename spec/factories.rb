# encoding: utf-8

FactoryGirl.define do
  factory :user do
    nick { Faker::Name.name }
    mail { Faker::Internet.email }
    password { SecureRandom.urlsafe_base64 }
    password_confirmation { |u| u.password }
    remember_token { SecureRandom.urlsafe_base64 }
    admin false
    study_path 1

    factory :admin do
      admin true
    end

    factory :physiker do
      study_path 3
    end
  end
end
