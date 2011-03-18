require 'open-uri'
require 'minify'

namespace :minify do
  task :install_less do
    File.open(File.join(Minify::JAVASCRIPT_DIR, 'less.js'), 'w') do |output|
      File.open('http://lesscss.googlecode.com/files/less-1.0.41.min.js') do |input|
        output.write(input.read)
      end
    end
  end
end