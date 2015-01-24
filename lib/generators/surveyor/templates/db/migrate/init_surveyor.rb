# encoding: UTF-8
class InitSurveyor < ActiveRecord::Migration

  def change

    create_table :surveys do |t|
      # Content
      t.integer :survey_version, :default => 0
      t.string :title
      t.text :description

      # Reference
      t.string :access_code
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab
      t.string :api_id

      # Display
      t.string :css_url
      t.string :custom_class
      t.integer :display_order

      # Expiry
      t.datetime :active_at
      t.datetime :inactive_at

      t.timestamps
    end
    add_index(:surveys, [:access_code, :survey_version], :name => 'surveys_access_code_version_idx', :unique => true)

    create_table :survey_sections do |t|
      # Context
      t.integer :survey_id

      # Content
      t.string :title
      t.text :description

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab

      # Display
      t.integer :display_order

      t.string :custom_class

      t.timestamps
    end

    create_table :questions do |t|
      # Context
      t.integer :survey_section_id
      t.integer :question_group_id
      t.integer :correct_answer_id

      # Content
      t.text :text
      t.text :short_text # For experts (ie non-survey takers). Short version of text
      t.text :help_text
      t.string :pick

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab
      t.string :api_id

      # Display
      t.integer :display_order
      t.string :display_type
      t.boolean :is_mandatory
      t.integer :display_width # used only for slider component (if needed)

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps
    end

    create_table :question_groups do |t|
      # Content
      t.text :text
      t.text :help_text

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab
      t.string :api_id

      # Display
      t.string :display_type

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps
    end

    create_table :answers do |t|
      # Context
      t.integer :question_id

      # Content
      t.text :text
      t.text :short_text #Used for presenting responses to experts (ie non-survey takers). Just a shorted version of the string
      t.text :help_text
      t.integer :weight # Used to assign a weight to an answer object (used for computing surveys that have numerical results) (I added this to support the Urology questionnaire -BLC)
      t.string :response_class # What kind of additional data does this answer accept?
      t.string :default_value

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab
      t.string :api_id

      # Display
      t.integer :display_order
      t.boolean :is_exclusive # If set it causes some UI trigger to remove (and disable) all the other answer choices selected for a question (needed for the WHR)
      t.integer :display_length # if smaller than answer.length the html input length will be this value
      t.string :display_type

      t.string :input_mask
      t.string :input_mask_placeholder

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps

    end

    create_table :response_sets do |t|
      # Context
      t.integer :user_id
      t.integer :survey_id

      # Content
      t.string :access_code #unique id for the object used in urls
      t.string :api_id

      # Expiry
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
    add_index(:response_sets, :access_code, :name => 'response_sets_ac_idx', :unique => true)

    create_table :responses do |t|
      # Context
      t.integer :response_set_id
      t.integer :question_id
      t.integer :survey_section_id

      # Content
      t.integer :answer_id
      t.datetime :datetime_value # handles date, time, and datetime (segregate by answer.response_class)
      t.string :api_id

      #t.datetime :time_value
      t.integer :integer_value
      t.float :float_value
      t.string :unit
      t.text :text_value
      t.string :string_value
      t.string :response_other #used to hold the string entered with "Other" type answers in multiple choice questions

      # arbitrary identifier used to group responses
      # the pertinent example here is Q: What's your car's make/model/year
      # group 1: Ford/Focus/2007
      # group 2: Toyota/Prius/2006
      t.string :response_group

      t.timestamps
    end
    add_index :responses, :survey_section_id

    create_table :dependencies do |t|
      # Context
      t.integer :question_id # the dependent question
      t.integer :question_group_id

      # Conditional
      t.string :rule

      # Result - TODO: figure out the dependency hook presentation options
      # t.string :property_to_toggle # visibility, class_name,
      # t.string :effect #blind, opacity

      t.timestamps
    end

    create_table :dependency_conditions do |t|
      # Context
      t.integer :dependency_id
      t.string :rule_key

      # Conditional
      t.integer :question_id # the conditional question
      t.string :operator

      # Value
      t.integer :answer_id
      t.datetime :datetime_value
      t.integer :integer_value
      t.float :float_value
      t.string :unit
      t.text :text_value
      t.string :string_value
      t.string :response_other

      t.timestamps
    end

    create_table :validations do |t|
      # Context
      t.integer :answer_id # the answer to validate

      # Conditional
      t.string :rule

      # Message
      t.string :message

      t.timestamps
    end

    create_table :validation_conditions do |t|
      # Context
      t.integer :validation_id
      t.string :rule_key

      # Conditional
      t.string :operator

      # Optional external reference
      t.integer :question_id
      t.integer :answer_id

      # Value
      t.datetime :datetime_value
      t.integer :integer_value
      t.float :float_value
      t.string :unit
      t.text :text_value
      t.string :string_value
      t.string :response_other
      t.string :regexp

      t.timestamps
    end

    create_table :survey_translations do |t|
      # Content
      t.integer :survey_id

      # Reference
      t.string :locale
      t.text :translation

      t.timestamps
    end


    # Add additional indexes for api_id to all required tables
    %w(surveys questions question_groups answers responses response_sets).each do |table|
      add_index table, 'api_id', :unique => true, :name => "uq_#{table}_api_id"
    end

  end
end

