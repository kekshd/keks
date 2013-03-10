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

  factory :hint do
    sort_hint { rand(100) }
    text { Faker::Lorem.sentences }
    question
  end

  factory :question do
    text { Faker::Lorem.sentences }
    sequence :ident do |n|
      "questIdent#{n}"
    end
    difficulty { Difficulty.ids.sample(1).first }
    study_path StudyPath.ids.first

    trait :parent_category do
      association :parent, factory: :category
    end

    trait :parent_answer do
      association :parent, factory: :answer
    end

    trait :hints do
      after(:create) do |question|
        FactoryGirl.create_list(:hint, rand(3), question: question)
      end
    end

    trait :answers do
      after(:create) do |question|
        FactoryGirl.create_list(:answer_wrong, 2, question: question)
        FactoryGirl.create_list(:answer_correct, 1, question: question)
      end
    end

    factory :question_parent_category, traits: [:parent_category, :hints, :answers]
    factory :question_parent_answer, traits: [:parent_answer, :hints, :answers]
    factory :question_no_answers, traits: [:parent_category, :hints]
    factory :question_with_answers, traits: [:hints, :answers]
  end


  factory :answer do
    text { Faker::Lorem.sentence }
    correct { rand(2) == 1 }
    sequence :ident do |n|
      "answIdent#{n}"
    end
    question

    factory :answer_correct do
      correct true
    end

    factory :answer_wrong do
      correct false
    end
  end

  factory :category do
    text { Faker::Lorem.sentences }
    title { Faker::Lorem.words }
    sequence :ident do |n|
      "catIdent#{n}"
    end

    factory :category_with_questions do
      after(:create) do |cat, evaluator|
        FactoryGirl.create_list(:question_with_answers, 10, parent: cat)
      end
    end
  end

  factory :stats do
    question
    user
    answer
    correct { |s| s.answer.correct? }
  end
end
