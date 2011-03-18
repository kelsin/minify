module Minify
  module Helper
    def minify_stylesheets(*groups)
      handle_css(*groups) + handle_less(*groups)
    end

    def minify_javascripts(*groups)
      handle_js(*groups)
    end

    private

    def less_file(file)
      ActionView::Helpers::AssetTagHelper.stylesheet_link_tag file, :rel => 'stylesheet/less'
    end

    def css_file(file)
      ActionView::Helpers::AssetTagHelper.stylesheet_link_tag file
    end

    def js_file(file)
      ActionView::Helpers::AssetTagHelper.javascript_link_tag file
    end

    def less_js_file
      if File.exists?(File.join(Minify::JAVASCRIPT_DIR, 'less.js'))
        js_file 'less.js'
      end
    end

    def handle_less(*groups)
      if Minify.dev?
        # Link to less files
        (groups.map do |group|
           Minify.less(group).map do |file|
             less_file(file)
           end
         end + [less_js_file]).flatten.compact.join
      end
    end

    def handle_css(*groups)
      groups.map do |group|
        group_file = File.join('minify', "#{group}.css")

        if Minify.dev? or !File.exists?(File.join(Minify::STYLESHEET_DIR, group_file))
          Minify.css(group).map do |file|
            css_file file
          end
        else
          css_file group_file
        end
      end.flatten.compact.join
    end
  end
end

# Include Minify helpers into ActionView::Base
::ActionView::Base.send(:include, Minify::Helper)
