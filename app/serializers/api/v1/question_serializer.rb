class Api::V1::QuestionSerializer < ActiveModel::Serializer
  attributes :text, :answers

  has_many :answers
end
