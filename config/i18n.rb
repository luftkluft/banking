require 'i18n'
I18n.load_path << Dir[File.expand_path('locale/') + '/*.yml']
I18n.config.available_locales = :en
