# Rails helpers
if defined?(Rails)
  require 'minify/helper'
  require 'minify/railtie'
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
  LESSC_DIR = File.join(STYLESHEET_DIR, 'minify', 'lessc')
  JAVASCRIPT_COMPRESSED_DIR = File.join(JAVASCRIPT_DIR, 'minify', 'js')
  STYLESHEET_COMPRESSED_DIR = File.join(JAVASCRIPT_DIR, 'minify', 'css')

  def self.load_configuration
    @conf = YAML.load(File.read(ASSET_FILE))
    @dev_envs = @conf[:development_environments] || ['development']

    @dev = defined?(Rails) ? (@dev_envs.include? Rails.env) : false
    @lessc = system("which lessc")

    @js_compressor = YUI::JavaScriptCompressor.new
    @css_compressor = YUI::CssCompressor.new
  end

  def self.lessc_available?
    !!@lessc
  end

  def self.yui_available?
    !!defined?(YUI)
  end

  def self.dev?
    @dev
  end

  def self.javascripts
    @conf['javascripts']
  end

  def self.stylesheets
    @conf['stylesheets']
  end

  def self.js(group)
    self.javascripts[group.to_s].select do |file|
      /\.js$/ =~ file
    end
  end

  def self.less(group)
    self.stylesheets[group.to_s].select do |file|
      /\.less$/ =~ file
    end
  end

  def self.css(group)
    self.stylesheets[group.to_s].select do |file|
      /\.css$/ =~ file
    end
  end

  def self.all_css(group)
    self.less(group) + self.css(group)
  end

  def self.group_file(group, type = :css)
    File.join(case type
              when :css
                STYLESHEET_DIR
              when :js
                JAVASCRIPT_DIR
              end, 'minify', "#{group}.#{type}")
  end

  def self.file_raw_path(file)
    case file
    when /\.js$/
      File.join(JAVASCRIPT_DIR, file)
    when /\.less$/
      File.join(STYLESHEET_DIR, file)
    when /\.css$/
      File.join(STYLESHEET_DIR, file)
    end
  end

  def self.file_compiled_path(file)
    case file
    when /\.js$/
      File.join(JAVASCRIPT_DIR, file)
    when /\.less$/
      if Minify.lessc_available?
        File.join(LESSC_DIR, file.sub(/\.less$/, '.css'))
      end
    when /\.css$/
      File.join(STYLESHEET_DIR, file)
    end
  end

  def self.file_compressed_path(file)
    if Minify.yui_available?
      case file
      when /\.js$/
        File.join(JAVASCRIPT_COMPRESSED_DIR, file)
      when /\.less$/
        File.join(STYLESHEET_COMPRESSED_DIR, file.sub(/\.less$/, '.css')) if self.file_compiled_path(file)
      when /\.css$/
        File.join(STYLESHEET_COMPRESSED_DIR, file)
      end
    else
      self.file_compiled_path(file)
    end
  end

  def self.compile(file)
    case file
    when /\.less$/
      if Minify.lessc_available?
        system("#{@lessc} #{Minify.file_raw_path(file)} #{Minify.file_compiled_path(file)}")
      end
    end
  end

  def self.compress(file)
    if Minify.yui_available?
      compiled = self.file_compiled_path(file)

      if compiled
        File.open(compiled, 'r') do |source|
          File.open(file_compressed_path(file), 'w') do |compressed|
            compressed.write(case compiled
                             when /\.css$/
                               @css_compressor
                             when /\.js$/
                               @js_compressor
                             end.compress(source))
          end
        end
      end
    end
  end
end

Minify.load_configuration if defined? Rails
