class Category < ActiveRecord::Base
  attr_reader :text

  has_many :questions, :as => :parent

end
