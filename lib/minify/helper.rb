module Minify
  module Helper
    include ::ActionView::Helpers::AssetTagHelper

    def minify_stylesheets(*groups)
      (handle_css(*groups) + handle_less(*groups)).html_safe
    end

    def minify_javascripts(*groups)
      handle_js(*groups).html_safe
    end

    private

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
      end
    end

    def handle_css(*groups)
      groups.map do |group|
        group_file = File.join('minify', "#{group}.css")

        if Minify.dev? or !File.exists?(File.join(Minify::STYLESHEET_DIR, group_file))
          Minify.css(group).map do |file|
            stylesheet_link_tag file
          end
        else
          stylesheet_link_tag group_file
        end
      end.flatten.compact.join
    end
  end
end

# Include Minify helpers into ActionView::Base
::ActionView::Base.send(:include, Minify::Helper)
