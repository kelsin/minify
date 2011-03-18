require 'open-uri'
require 'minify'

namespace :minify do
  namespace :less do
    desc "Download less.js to #{Minify::JAVASCRIPT_DIR}"
    task :install do
      File.open(File.join(Minify::JAVASCRIPT_DIR, 'less.js'), 'w') do |output|
        open('http://lesscss.googlecode.com/files/less-1.0.41.min.js') do |input|
          output.write(input.read)
        end
      end
    end

    desc "Compile .less files"
    task :compile do
      if Minify.lessc_available?
        Minify.stylesheets.each do |group|
          puts "Group #{group}"

          Minify.less(group).each do |file|
            puts "Compiling #{file}"
            Minify.compile(file)
          end
        end
      end
    end
  end

  namespace :css do
    desc "Run YUI Compressor on all css files"
    task :compress do
      if Minify.yui_available?
        Minify.stylesheets.each do |group|
          puts "Compressing CSS Group: #{group}"

          Minify.all_css(group).map do |file|
            Minify.file_compiled_path(file)
          end.compact.each do |compiled|
            puts "Compressing: #{compiled}"
            Minify.compress(compiled)
          end
        end
      end
    end

    desc "Compact all minified css into group files"
    task :compact do
      Minify.stylesheets.each do |group|
        puts "Compacting CSS Group: #{group}"

        File.open(Minify.group_file(group, :css), 'w') do |output|
          Minify.all_css(group).map do |file|
            Minify.file_compressed_path(file)
          end.compact.each do |compressed|
            puts "Adding: #{compressed}"

            File.open(compressed, 'r') do |input|
              output.write(input.read)
            end
          end
        end
      end
    end
  end

  namespace :js do
    desc "Run YUI Compressor on all js files"
    task :compress do
      if Minify.yui_available?
        Minify.javascripts.each do |group|
          puts "Compressing JS Group: #{group}"

          Minify.js(group).each do |file|
            puts "Compressing: #{file}"
            Minify.compress(file)
          end
        end
      end
    end

    desc "Compact all minified css into group files"
    task :compact do
      Minify.javascripts.each do |group|
        puts "Compacting JS Group: #{group}"

        File.open(Minify.group_file(group, :js), 'w') do |output|
          Minify.js(group).map do |file|
            Minify.file_compressed_path(file)
            end.each do |compressed|
            puts "Adding: #{compressed}"

            File.open(compressed, 'r') do |input|
              output.write(input.read)
            end
          end
        end
      end
    end
  end
end
