class Hint < ActiveRecord::Base
  attr_accessible :sort_hint, :question_id, :text

  belongs_to :question

  validates :text, presence: true
  validates :question_id, presence: true
  validates :sort_hint, numericality: true, allow_blank: true

  def dot
    txt = 'H: ' + text.gsub('"', '')[0..15]
    %(#{dot_id} [label="#{txt}", shape=none];)
  end

  def dot_id
    'h' + text.gsub(/[^a-z0-9_]/i, '')
  end
end
