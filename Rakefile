begin
  require 'bundler/gem_tasks'
rescue LoadError
  puts 'Cannot load bundler/gem_tasks'
end

task default: :prepare

task prepare: "ext/lib/libsass.so"

file "ext/lib/libsass.so" do
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  cd "ext/libsass"
  sh 'make lib/libsass.so LDFLAGS="-Wall -O2"'
  cd gem_dir
end

task test: :prepare do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end

task :submodule do
  sh "git submodule update --init"
end
