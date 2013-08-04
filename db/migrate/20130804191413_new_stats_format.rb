class NewStatsFormat < ActiveRecord::Migration
  def self.up
    add_column :stats, :selected_answers, :string
    add_column :stats, :skipped, :boolean, :default => false

    Stat.unscoped.all.each do |s|
      if s.answer_id == -1
        s.selected_answers = []
        s.skipped = true
      else
        s.selected_answers = [s.answer_id]
      end
      s.save
    end

    remove_column :stats, :answer_id
  end

  def self.down
    add_column :stats, :answer_id, :string

    Stat.unscoped.all.each do |s|
      # this will lose information
      if s.skipped?
        s.answer_id = -1
      else
        s.answer_id = s.selected_answers[0]
      end
      s.save
    end

    remove_column :stats, :selected_answers
    remove_column :stats, :skipped
  end
end
