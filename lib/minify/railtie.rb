require 'rails'

module Minify
  class Railtie < Rails::Railtie
    railtie_name :minify

    rake_tasks do
      load 'tasks/minify.rake'
    end
  end
end

