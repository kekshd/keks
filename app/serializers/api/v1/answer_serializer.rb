class Api::V1::AnswerSerializer < ActiveModel::Serializer
  attributes :text, :correct
end
