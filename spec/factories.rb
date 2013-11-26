# encoding: utf-8

FactoryGirl.define do
  factory :user do
    nick { Faker::Name.name }
    mail { Faker::Internet.email }
    password { SecureRandom.urlsafe_base64 }
    password_confirmation { |u| u.password }
    remember_token { SecureRandom.urlsafe_base64 }
    admin false
    reviewer false
    study_path 1

    factory :admin do
      admin true
    end

    factory :reviewer do
      reviewer true
      after(:create) do |user|
        FactoryGirl.create_list(:review, 5, user: user)
      end
    end

    factory :physiker do
      study_path 3
    end

    trait :stats do
      after(:create) do |user|
        ((rand*7).to_i + 1).times {
          q = FactoryGirl.create(:question_with_answers)
          FactoryGirl.create_list(:stat, (rand*5).to_i + 1 , user: user, question: q)
        }
      end
    end

    factory :user_with_stats, traits: [:stats]
  end

  factory :hint do
    sort_hint { rand(100) }
    text { Faker::Lorem.sentence(10) }
    question
  end

  factory :question do
    content_changed_at Time.now - 1000
    text { Faker::Lorem.sentence(30) }
    sequence :ident do |n|
      "questIdent#{n}"
    end
    difficulty { Difficulty.ids.sample }
    study_path StudyPath.ids.first
    released true

    trait :parent_category do
      association :parent, factory: :category
    end

    trait :parent_answer do
      association :parent, factory: :answer
    end

    trait :parent_answer_parent do
      association :parent, factory: :answer
    end

    trait :hints do
      after(:create) do |question|
        FactoryGirl.create_list(:hint, rand(3) + 1, question: question)
      end
    end

    trait :answers do
      after(:create) do |question|
        FactoryGirl.create_list(:answer_wrong, 2, question: question)
        FactoryGirl.create_list(:answer_correct, 1, question: question)
        question.reload
      end
    end

    trait :subs do
      answers
      after(:create) do |question|
        FactoryGirl.create_list(:question_parent_answer, 2, parent: question.answers.sample)
        FactoryGirl.create_list(:category_with_questions, 2, answers: [question.answers.sample], is_root: false)
        FactoryGirl.create_list(:question_parent_answer, 2)
      end
    end

    factory :question_parent_category_subs, traits: [:parent_category, :subs]
    factory :question_parent_category, traits: [:parent_category, :hints, :answers]
    factory :question_parent_answer, traits: [:parent_answer, :hints, :answers]
    factory :question_parent_answer_subs, traits: [:parent_answer, :subs]
    factory :question_subs, traits: [:subs]
    factory :question_no_answers, traits: [:parent_category, :hints]
    factory :question_with_answers, traits: [:hints, :answers]

    factory :question_matrix do
      after(:create) do |question|
        FactoryGirl.create_list(:answer_matrix, 1, question: question)
        question.reload
      end
    end

    factory :question_with_many_good_reviews do
      after(:create) do |question|
        FactoryGirl.create_list(:review, 5, question: question, okay: true)
      end
    end
  end


  factory :answer do
    text { Faker::Lorem.sentence }
    correct { rand(2) == 1 }
    question

    factory :answer_correct do
      correct true
    end

    factory :answer_wrong do
      correct false
    end

    factory :answer_matrix do
      correct true
      text { "$\\begin{pmatrix}3\\\\3\\\\18\\end{pmatrix}$" }
    end

    factory :answer_with_subquestion do
      after(:create) do |answer|
        FactoryGirl.create_list(:question_with_answers, 1, parent: answer)
      end
    end
  end

  factory :category do
    text { Faker::Lorem.sentence }
    title { Faker::Lorem.words.join " " }
    sequence :ident do |n|
      "catIdent#{n}"
    end
    released true
    is_root true

    factory :category_with_questions do
      after(:create) do |cat, evaluator|
        FactoryGirl.create_list(:question_with_answers, 10, parent: cat)
      end
    end
  end

  factory :stat do
    association :question, :factory => [:question_with_answers]
    user
    selected_answers do |s|
      [s.question.answers.sample.id]
    end
    correct do |s|
      s.selected_answers.all? { |a| Answer.find(a).correct? }
    end

    factory :stat_skipped do
      skipped true
      selected_answers []
      correct false
    end
  end

  factory :review do
    association :question, :factory => [:question_parent_category]
    user
    okay { rand(2) == 1 }
    comment { Faker::Lorem.sentence }
    created_at Time.now
    updated_at Time.now
  end

  factory :text_storage do
    value { Faker::Lorem.sentence }
    sequence :ident do |n|
      "textStorageIdent#{n}"
    end

    factory :text_storage_empty do
      value ""
    end
  end

  factory :perf do
    load_time { (rand*1000).to_i }
    user_id { (rand*10).to_i + 1 }
    url { Faker::Internet.url }
    agent { Faker::Name.title + " Browser" }
  end
end
