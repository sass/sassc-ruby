begin
  require 'bundler/gem_tasks'
rescue LoadError
  puts 'Cannot load bundler/gem_tasks'
end

require 'tasks/libsass'

task default: :test

desc "Run all tests"
task test: 'libsass:compile' do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
