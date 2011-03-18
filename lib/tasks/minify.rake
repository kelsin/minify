require 'open-uri'
require 'fileutils'
require 'minify'

namespace :minify do
  task :mkdir do
    FileUtils.mkdir(File.join(Minify::STYLESHEET_DIR, 'minify')) unless File.exists?(File.join(Minify::STYLESHEET_DIR, 'minify'))
    FileUtils.mkdir(File.join(Minify::JAVASCRIPT_DIR, 'minify')) unless File.exists?(File.join(Minify::JAVASCRIPT_DIR, 'minify'))
  end

  desc "Build all js and css files for production"
  task :build => ['minify:css:build', 'minify:js:build'] do
  end

  namespace :less do
    task :mkdir => 'minify:mkdir' do
      FileUtils.mkdir(Minify::LESSC_DIR) unless File.exists?(Minify::LESSC_DIR)
    end

    desc "Compile .less files"
    task :compile => :mkdir do
      if Minify.lessc_available?
        Minify.stylesheets.keys.each do |group|
          puts "Compiling less group: #{group}"

          Minify.less(group).each do |file|
            puts "... compiling: #{file}"
            Minify.compile(file)
          end
        end
      end
    end

    desc "Download less.js to #{Minify::JAVASCRIPT_DIR}"
    task :install do
      puts "Downloading #{Minify::LESS_JS} to #{File.join(Minify::JAVASCRIPT_DIR, 'less.js')}"
      File.open(File.join(Minify::JAVASCRIPT_DIR, 'less.js'), 'w') do |output|
        open(Minify::LESS_JS) do |input|
          output.write(input.read)
        end
      end
    end
  end

  namespace :css do
    task :mkdir => 'minify:mkdir' do
      FileUtils.mkdir(Minify::STYLESHEET_COMPRESSED_DIR) unless File.exists?(Minify::STYLESHEET_COMPRESSED_DIR)
    end

    desc "Compile, compress and compact all css files"
    task :build => ['minify:less:compile', :compress, :compact] do
    end

    desc "Run YUI Compressor on all css files"
    task :compress => :mkdir do
      if Minify.yui_available?
        Minify.stylesheets.keys.each do |group|
          puts "Compressing css group: #{group}"

          Minify.all_css(group).map do |file|
            puts "... compressing: #{compiled}"
            Minify.compress(file)
          end
        end
      end
    end

    desc "Compact all minified css into group files"
    task :compact => :mkdir do
      Minify.stylesheets.keys.each do |group|
        puts "Compacting css group: #{group}"

        File.open(Minify.group_file(group, :css), 'w') do |output|
          Minify.all_css(group).map do |file|
            Minify.file_compressed_path(file)
          end.compact.each do |compressed|
            puts "... adding: #{compressed}"

            File.open(compressed, 'r') do |input|
              output.write(input.read)
            end
          end
        end
      end
    end
  end

  namespace :js do
    task :mkdir => 'minify:mkdir' do
      FileUtils.mkdir(Minify::JAVASCRIPT_COMPRESSED_DIR) unless File.exists?(Minify::JAVASCRIPT_COMPRESSED_DIR)
    end

    desc "Compress and compact all js files"
    task :build => [:compress, :compact] do
    end

    desc "Run YUI Compressor on all js files"
    task :compress => :mkdir do
      if Minify.yui_available?
        Minify.javascripts.keys.each do |group|
          puts "Compressing js group: #{group}"

          Minify.js(group).each do |file|
            puts "... compressing: #{file}"
            Minify.compress(file)
          end
        end
      end
    end

    desc "Compact all minified css into group files"
    task :compact => :mkdir do
      Minify.javascripts.keys.each do |group|
        puts "Compacting js group: #{group}"

        File.open(Minify.group_file(group, :js), 'w') do |output|
          Minify.js(group).map do |file|
            Minify.file_compressed_path(file)
            end.each do |compressed|
            puts "... adding: #{compressed}"

            File.open(compressed, 'r') do |input|
              output.write(input.read)
            end
          end
        end
      end
    end
  end
end
