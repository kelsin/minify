require 'rails'

module Minify
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/minify.rake'
    end
  end
end

