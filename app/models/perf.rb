class Perf < ActiveRecord::Base
  attr_accessible :agent, :load_time, :url
  # technically this perf stat belongs to a user, but wo do not actually
  # care about that.
  attr_protected :user_id

  validates :url,       presence: true
  validates :load_time, presence: true
  validates :agent,     presence: true

  before_save :harmonize_url

  protected
  def harmonize_url
    u = URI.parse(self.url)
    suburi = ENV['RAILS_RELATIVE_URL_ROOT'] || ""

    # remove host
    self.url = u.path.sub(/^#{suburi}/, "").sub(/^\//, "")
    self.url << "?#{u.query}" if u.query
    self.url << "##{u.fragment}" if u.fragment
  end
end
