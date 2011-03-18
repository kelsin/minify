# Rails helpers
if defined?(Rails)
  require 'minify/helper'
end

# YUI Compressor
begin
  require 'yui/compressor'
rescue LoadError => e
  # Failure is ok, won't compress files in this case, only concat them
end

# Other normal requires
require 'yaml'

module Minify
  ROOT = File.expand_path((defined?(Rails) && Rails.root.to_s.length > 0) ? Rails.root : '.')
  ASSET_FILE = File.join(ROOT, 'config', 'assets.yml')
  JAVASCRIPT_DIR = File.join(ROOT, 'public', 'javascripts')
  STYLESHEET_DIR = File.join(ROOT, 'public', 'stylesheets')

  def self.lessc_available?
    system("which -s lessc")
  end

  def self.yui_available?
    !!defined?(YUI)
  end

  def self.load_configuration
    @conf = YAML.load(File.read(ASSET_FILE))
    @dev_envs = @conf[:development_environments] || ['development']

    @dev = defined?(Rails) ? (@dev_envs.include? Rails.env) : false
  end

  def self.dev?
    @dev
  end

  def self.javascripts
    @conf[:javascripts]
  end

  def self.stylesheets
    @conf[:stylesheets]
  end

  def self.less(group)
    self.stylesheets[group].select do |file|
      /\.less$/ =~ file
    end
  end

  def self.css(group)
    self.stylesheets[group].select do |file|
      /\.css$/ =~ file
    end
  end
end

Minify.load_configuration if defined? Rails
