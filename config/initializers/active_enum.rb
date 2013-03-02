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
  value :id => 2, :name => 'Bsc Mathe'
  value :id => 3, :name => 'Bsc Physik'
  value :id => 4, :name => 'Lehramt'
end

class EnrollmentKeys < ActiveEnum::Base
  value :id => 1, :name => 'TestEnrollment'
end
