class Answer < ActiveRecord::Base
  #self.table_name = "#{Rails.configuration.surveyor.table_prefix}#{self.compute_table_name}"

  include Surveyor::Models::AnswerMethods
end
