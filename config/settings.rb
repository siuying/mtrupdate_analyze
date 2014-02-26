require 'settingslogic'

class Settings < Settingslogic
  source "#{File.join(File.dirname(__FILE__), '..')}/config/application.yml"
end