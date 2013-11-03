# via http://stackoverflow.com/a/7840900/1684530
class ActiveRecord::Base
  def self.escape_sql(clause, *rest)
    self.send(:sanitize_sql_array, rest.empty? ? clause : ([clause] + rest))
  end
end
