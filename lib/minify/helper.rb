module Minify
  module Helper
    def minify_stylesheets(*groups)
    end

    def minify_javascripts(*groups)
    end

    private
  end
end

# Include Minify helpers into ActionView::Base
::ActionView::Base.send(:include, Minify::Helper)
