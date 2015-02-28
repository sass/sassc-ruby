require "bundler/gem_tasks"

task default: :prepare

task prepare: "ext/lib/libsass.so"

file "ext/lib/libsass.so" do
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  cd "ext/libsass"
  sh "make lib/libsass.so"
  cd gem_dir
end

task test: :prepare do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
