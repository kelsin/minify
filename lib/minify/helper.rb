module Minify
  module Helper
    include ::ActionView::Helpers::AssetTagHelper

    def minify(*groups)
      minify_stylesheets(*groups) + minify_javascripts(*groups)
    end

    def minify_stylesheets(*groups)
      (handle_css(*groups) + handle_less(*groups)).html_safe
    end

    def minify_javascripts(*groups)
      handle_js(*groups).html_safe
    end

    private

    def handle_js(*groups)
      groups.map do |group|
        if Minify.dev?
          Minify.js(group).map do |file|
            javascript_include_tag file
          end
        else
          javascript_include_tag Minify.group_file(group, :js)
        end
      end.flatten.compact.join
    end

    def handle_less(*groups)
      if Minify.dev?
        # Link to less files
        less_files = groups.map do |group|
          Minify.less(group).map do |file|
            stylesheet_link_tag file, :rel => 'stylesheet/less'
          end
        end.flatten.compact

        unless less_files.empty?
          less_files << javascript_include_tag('less.js')
        end

        less_files.join
      else
        ''
      end
    end

    def handle_css(*groups)
      groups.map do |group|
        if Minify.dev?
          Minify.css(group).map do |file|
            stylesheet_link_tag file
          end
        else
          stylesheet_link_tag Minify.group_file(group, :css)
        end
      end.flatten.compact.join
    end
  end
end

# Include Minify helpers into ActionView::Base
::ActionView::Base.send(:include, Minify::Helper)
