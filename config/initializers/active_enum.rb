# Form helper integration
# require 'active_enum/form_helpers/formtastic'  # for Formtastic <2
# require 'active_enum/form_helpers/formtastic2' # for Formtastic 2.x

ActiveEnum.setup do |config|

  # Extend classes to add enumerate method
  # config.extend_classes = [ ActiveRecord::Base ]

  # Return name string as value for attribute method
  # config.use_name_as_value = false

  # Storage of values (:memory, :i18n)
  # config.storage = :memory

end


class StudyPath < ActiveEnum::Base
  value :id => 1, :name => ' '
  value :id => 2, :name => 'B.Sc. Mathe'
  value :id => 3, :name => 'B.Sc. Physik'
  value :id => 4, :name => 'Lehramt Mathe'
  value :id => 5, :name => 'Lehramt Physik'
  value :id => 6, :name => 'B.Sc. Informatik'
  value :id => 7, :name => 'Lehramt Informatik'
end

class Difficulty < ActiveEnum::Base
  value :id => 5, :name => 'Definitionen'
  value :id => 10, :name => 'Leicht'
  value :id => 20, :name => 'Mittel'
  value :id => 30, :name => 'Schwer'
end

class EnrollmentKeys < ActiveEnum::Base
  value :id => 1, :name => 'TestEnrollment'
  value :id => 2, :name => '2013LA2'
  value :id => 3, :name => 'mathphys2013'
end
