class NewStatsFormat < ActiveRecord::Migration
  def self.up
    # can’t use add_column, because for some reason the columns are not
    # directly available
    execute(%|ALTER TABLE stats ADD COLUMN "skipped" boolean DEFAULT 'f'|)
    execute(%|ALTER TABLE stats ADD COLUMN "selected_answers" varchar(255)|)

    # don’t print the update statement for each stat
    ActiveRecord::Base.logger.quietly do
      # XXX: if you get undefined constat here, temporarily comment out
      # the “config.threadsafe” in config/application.rb. Appears to be a
      # rails bug (see https://rails.lighthouseapp.com/projects/8994/tickets/2506-models-are-not-loaded-in-migrations-when-configthreadsafe-is-set )
      Stat.unscoped.all.each do |s|
        skipped, selansw = nil, nil
        if s.answer_id == -1
          selansw = ""
          skipped = 't'
        else
          skipped = 'f'
          selansw = "#{s.answer_id}"
        end

        execute "UPDATE stats SET skipped = '#{skipped}', selected_answers = '#{selansw}' WHERE id = '#{s.id}'"
      end
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
      s.save(:validate => false)
    end

    remove_column :stats, :selected_answers
    remove_column :stats, :skipped
  end
end
