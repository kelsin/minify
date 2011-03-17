if defined?(Rails)
  require 'minify/helper'
end

begin
  require 'yui/compressor'
rescue LoadError => e
  # Failure is ok, won't compress files in this case, only concat them
end

module Minify
  def self.lessc_available?
    system("which -s lessc")
  end

  def self.yui_available?
    !!defined?(YUI)
  end
end
