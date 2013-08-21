# encoding: utf-8

class TextStorage < ActiveRecord::Base
  attr_accessible :ident, :value

  def TextStorage.get(ident)
    x = TextStorage.where(ident: ident).pluck(:value)
    return "Für diesen Eintrag (#{ident}) wurde noch kein Text gespeichert." unless x
    x
  end
end
