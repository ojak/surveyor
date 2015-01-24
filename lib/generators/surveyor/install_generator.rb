# encoding: UTF-8
require 'rails/generators'

module Surveyor
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path("../templates", __FILE__)

    desc "Generate surveyor README, migrations, assets and sample survey"
    class_option :skip_migrations, :type => :boolean, :desc => "skip migrations, but generate everything else"

    SURVEYOR_MIGRATIONS = %w()

    def readme
      copy_file "../../../../README.md", "#{vendor_dir}/README.md"
    end

    def migrations
      unless options[:skip_migrations]
        check_for_orphaned_migration_files

        # increment migration timestamps to prevent collisions. copied functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
        SURVEYOR_MIGRATIONS.each_with_index do |name, i|
          unless (prev_migrations = check_for_existing_migrations(name)).empty?
            prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{name}.rb$/)[1]
          end
          copy_file("db/migrate/#{name}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{name}.rb")
        end
      end
    end

    def routes
      route('mount Surveyor::Engine => "/surveys", :as => "surveyor"')
    end

    def assets
      directory "app/assets"
      copy_file "vendor/assets/stylesheets/custom.sass"
    end

    def surveys
      survey_dir = "#{vendor_dir}/surveys"
      copy_file "#{survey_dir}/kitchen_sink_survey.rb"
      copy_file "#{survey_dir}/quiz.rb"
      copy_file "#{survey_dir}/date_survey.rb"
      copy_file "#{survey_dir}/languages.rb"
      directory "#{survey_dir}/translations"
    end

    def locales
      directory "config/locales"
    end

    private

      def check_for_existing_migrations(name)
        Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{name}.rb$/)
      end

      def check_for_orphaned_migration_files
        migration_files = Dir[File.join(self.class.source_root, 'db/migrate/*.rb')]
        orphans = migration_files.collect { |f| File.basename(f).sub(/\.rb$/, '') } - SURVEYOR_MIGRATIONS
        unless orphans.empty?
          fail "%s migration%s not added to SURVEYOR_MIGRATIONS: %s" % [
            orphans.size,
            orphans.size == 1 ? '' : 's',
            orphans.join(', ')
          ]
        end
      end

      def vendor_dir
        "vendor/surveyor"
      end
  end
end
