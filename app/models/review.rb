# encoding: utf-8


class Review < ActiveRecord::Base
  attr_accessible :comment, :okay, :votes

  belongs_to :question, inverse_of: :reviews
  belongs_to :user

  serialize :votes

  before_save do
    Rails.cache.write(:reviews_last_update, Time.now)
  end

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.votes || {})[:#{method_name}] || 0.5
        end
        def #{method_name}=(value)
          self.votes ||= {}
          self.votes[:#{method_name}] = value.to_f
        end
        attr_accessible :#{method_name}
      "
    end
  end

  serialized_attr_accessor :difficulty, :learneffect, :fun
  validates :difficulty, :inclusion => 0..10



  validates_uniqueness_of :question_id, :scope => :user_id

  belongs_to :user
  belongs_to :question

  def question_updated_since?
    return false if self.new_record?
    updated_at < question.content_changed_at
  end






  def Review.filter(name)
    name = name.to_sym
    return @@filters[name].dup if @@filters[name]
    raise "There is no “#{name}” filter."
  end

  def Review.get_filters
    @@filters.keys
  end

  private

  @@filters = {
    # all ##############################################################
    all: {
      title: "Alle Fragen",
      link_title: "Alle Fragen",
      text: "",
      questions: lambda { |current_user|
        return Question.all
      }
    },

    # all ##############################################################
    not_okay: {
      title: "nicht-okay-e Fragen",
      link_title: "Fragen mit „nicht okay“",
      text: "Diese Fragen wurden von mindestens einer Person als nicht-okay markiert.",
      questions: lambda { |current_user|
        return Review.where(okay: false).map { |r| r.question }.uniq
      }
    },

    # no reviews #######################################################
    no_reviews: {
      title: "Keine Reviews",
      link_title: "Fragen ohne Reviews",
      text: "Folgende Fragen haben genau null Reviews.",
      questions: lambda { |current_user|
        questions = Question.includes(:reviews, :parent).all
        questions.reject! { |q| q.reviews.any? }
        return questions
      }
    },

    # good but needs more ##############################################
    good_but_needs_more_reviews: {
      title: "0 < |ok| < #{REVIEW_MIN_REQUIRED_REVIEWS} und ⌐ok = 0",
      link_title: "0 < |ok| < #{REVIEW_MIN_REQUIRED_REVIEWS} und ⌐ok = 0",
      text: "Oder liebevoll: Fragen mit wenig Arbeit. Hier werden alle Fragen gelistet, die jemand als okay/richtig befunden hat. Trotzdem sollte nochmal jemand drüber schauen. Insgesamt benötigt eine Frage 3 „okay“ Reviews.",
      questions: lambda { |current_user|
        questions = Question.includes(:reviews, :parent).all
        questions.reject! do |q|
          q.reviews.none? || \
            q.reviews.count >= REVIEW_MIN_REQUIRED_REVIEWS || \
            q.reviews.any? { |r| !r.okay? }
        end
        return questions
      }
    },

    # no reviews #######################################################
    enough_good_reviews: {
      title: "#{REVIEW_MIN_REQUIRED_REVIEWS}+ okay, 0 nicht-okay",
      link_title: "#{REVIEW_MIN_REQUIRED_REVIEWS}+ okay, 0 nicht-okay",
      text: "Hier werden alle „freischaltbaren“ Fragen aufgelistet. D.h. solche, die <b>noch nicht freigeschalten</b> sind aber genug – und ausschließlich – positive Reviews haben. ".html_safe,
      questions: lambda { |current_user|
        questions = Question.where(released: false).includes(:reviews, :parent).all
        questions.keep_if do |q|
          q.reviews.count >= REVIEW_MIN_REQUIRED_REVIEWS && \
            q.reviews.all? { |r| r.okay? }
        end
        return questions
      }
    },

    # needs more reviews, not reviewed by current ######################
    need_more_reviews: {
      title: "Fragen, die ein Review brauchen",
      link_title: "reviewbare Fragen",
      text: "Nachfolgende Fragen haben bisher zu wenig Reviews erhalten. Du hast diese Fragen noch nie reviewt.",
      hide_in_menu: true,
      questions: lambda { |current_user|
        reviews = Review.where(user_id: current_user)
        reviewed_question_ids = reviews.pluck(:question_id)

        questions = Question.includes(:reviews, :parent).all
        questions_need_review = questions.select do |q|
          q.reviews.size < REVIEW_MIN_REQUIRED_REVIEWS \
            and !reviewed_question_ids.include?(q.id)
        end
        return questions_need_review
      }
    },

    # needs more reviews, not reviewed by current ######################
    updated: {
      title: "Seit Deinem letztem Review aktualisiert",
      link_title: "Aktualisierte Fragen",
      text: "Du hast diese Fragen bereits einmal reviewed. Die Frage wurde jedoch aktualisiert seitdem Du das getan hast. Bitte prüfe ob Deine Anmerkungen noch stimmen und ändere ggf. Deine Einstellungen.",
      questions: lambda { |current_user|
        reviews = Review.where(user_id: current_user)
        reviews = reviews.select { |r| r.question_updated_since? }
        return reviews.map { |r| r.question }.uniq
      }
    }
  }
end
