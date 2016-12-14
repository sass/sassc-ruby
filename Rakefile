require 'bundler/gem_tasks'
require 'tasks/libsass'

task default: :test

desc "Run all tests"
task test: 'libsass:compile' do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
