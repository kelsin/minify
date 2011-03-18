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

  LESS_JS = 'http://lesscss.googlecode.com/files/less-1.0.41.min.js'

  def self.load_configuration
    @conf = YAML.load(File.read(ASSET_FILE))
    @dev_envs = @conf[:development_environments] || ['development']

    @dev = defined?(Rails) ? (@dev_envs.include? Rails.env) : false
    @lessc = system('which lessc')

    if self.yui_available?
      @js_compressor = YUI::JavaScriptCompressor.new
      @css_compressor = YUI::CssCompressor.new
    end
  end

  # Returns true if we can find lessc in the current $PATH
  def self.lessc_available?
    !!@lessc
  end

  # Returns true if the yui-compressor gem is available
  def self.yui_available?
    !!defined?(YUI)
  end

  # Returns true if we are in a development Rails environment
  def self.dev?
    @dev
  end

  # Returns the collection of javascript groups from assets.yml
  def self.javascripts
    @conf['javascripts']
  end

  # Returns the collection of stylesheet groups from assets.yml
  def self.stylesheets
    @conf['stylesheets']
  end

  # Returns the list of javascript files from a group
  def self.js(group)
    self.javascripts[group.to_s].select do |file|
      /\.js$/ =~ file
    end
  end

  # Returns the list of less files from a group
  def self.less(group)
    self.stylesheets[group.to_s].select do |file|
      /\.less$/ =~ file
    end
  end

  # Returns the list of css files from a group
  def self.css(group)
    self.stylesheets[group.to_s].select do |file|
      /\.css$/ =~ file
    end
  end

  # Returns the list of css and less files from a group
  def self.all_css(group)
    self.less(group) + self.css(group)
  end

  # Returns the path of the group file for a certain group name and type (:js or
  # :css)
  def self.group_file(group, type = :css)
    File.join(case type
              when :css
                STYLESHEET_DIR
              when :js
                JAVASCRIPT_DIR
              end, 'minify', "#{group}.#{type}")
  end

  # Returns the full path to the original raw version of an asset file
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

  # Returns the path of the compiled version of an asset file (or nil if
  # unavailable)
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

  # Returns the path of the compressed version of an asset file (or nil if
  # unavailable)
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

  # Compiles an asset file
  def self.compile(file)
    case file
    when /\.less$/
      if Minify.lessc_available?
        cmd = "#{@lessc} #{Minify.file_raw_path(file)} #{Minify.file_compiled_path(file)}"
        puts "... running: #{cmd}"
        system cmd
      end
    end
  end

  # Compresses an asset file
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
