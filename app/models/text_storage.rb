# encoding: utf-8

class TextStorage < ActiveRecord::Base
  attr_accessible :ident, :value
  validates :ident, uniqueness: true

  def TextStorage.get(ident)
    x = TextStorage.where(ident: ident).pluck(:value).first
    return "Für diesen Eintrag (#{ident}) wurde noch kein Text gespeichert." unless x
    x
  end
end
