module Minify
  module Helper
    include ::ActionView::Helpers::AssetTagHelper

    def minify(*groups)
      minify_stylesheets(*groups) + minify_javascripts(*groups)
    end

    def minify_stylesheets(*groups)
      handle_css(*groups).html_safe
    end

    def minify_javascripts(*groups)
      handle_js(*groups).html_safe
    end

    private

    def handle_js(*groups)
      js_files = groups.map do |group|
        if Minify.dev?
          Minify.js(group).map do |file|
            javascript_include_tag file
          end
        else
          javascript_include_tag "minify/#{group}.js"
        end
      end.flatten.compact.join

      if Minify.dev? and self.includes_less?(*groups)
        js_files += javascript_include_tag('less.js')
      end

      return js_files
    end

    def handle_css(*groups)
      groups.map do |group|
        if Minify.dev?
          Minify.css(group).map do |file|
            if /\.less$/ =~ file
              stylesheet_link_tag file, :rel => 'stylesheet/less'
            else
              stylesheet_link_tag file
            end
          end
        else
          stylesheet_link_tag "minify/#{group}.css"
        end
      end.flatten.compact.join
    end
  end
end

# Include Minify helpers into ActionView::Base
::ActionView::Base.send(:include, Minify::Helper)
