require 'spec_helper'

describe Review do
  let(:review) { FactoryGirl.build(:review) }
  let!(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:another_reviewer) { FactoryGirl.create(:reviewer) }

  it "raises when given invalid filter" do
    expect(lambda { Review.filter("does not exist") }).to raise_error
  end

  it "can be saved" do
    FactoryGirl.build(:review).should be_valid
  end

  it "can store serialized attributes" do
    review.difficulty = 1.0
    review.save
    review.reload
    expect(review.difficulty).to eql(1.0)
    expect(review.votes).to eql({difficulty: 1.0})
  end

  context "(many exist)" do
    before(:each) do
      10.times { FactoryGirl.create(:review, user: reviewer) }
      FactoryGirl.create(:question)
    end

    def get_questions(filter, user = nil)
      user ||= reviewer
      Review.filter(filter)[:questions].call(user)
    end

    # note: we can assume question count == review count in these tests
    # do to the way the review factory works

    it "finds all questions with all filter" do
      expect(get_questions(:all).size).to eql(Question.count)
    end

    it "finds all questions with one not okay review" do
      not_okay = Review.where(okay: false).count
      expect(get_questions(:not_okay).size).to eql(not_okay)
    end

    it "finds questions without review" do
      FactoryGirl.create(:question)
      expect(get_questions(:no_reviews).size).to eql(2)
    end

    it "finds good questions which need more reviews" do
      okay = Review.where(okay: true).reject { |r| r.question.released? }.size
      expect(get_questions(:good_but_needs_more_reviews).size).to eql(okay)
    end

    it "finds good questions which have enough reviews" do
      q = FactoryGirl.create(:question_with_many_good_reviews)
      q.released = false
      q.save
      q.reload
      expect(get_questions(:enough_good_reviews).size).to eql(1)
    end

    it "finds questions which need reviews" do
      r = FactoryGirl.create(:review, user: another_reviewer)

      def reviewable(user)
        Question.all.reject do |q|
          q.reviews.pluck(:user_id).include?(user.id)
        end
      end

      qs = get_questions(:need_more_reviews, reviewer)
      expect(qs.size).to eql(reviewable(reviewer).size)

      qs = get_questions(:need_more_reviews, another_reviewer)
      expect(qs.size).to eql(reviewable(another_reviewer).size)
      expect(qs).not_to include(r.question)
    end
  end
end
