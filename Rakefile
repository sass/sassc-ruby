begin
  require 'bundler/gem_tasks'
rescue LoadError
  puts 'Cannot load bundler/gem_tasks'
end

task default: :test

require 'rake/extensiontask'
Rake::ExtensionTask.new do |ext|
  ext.name = 'libsass'
  ext.ext_dir = 'ext'
  ext.lib_dir = 'lib/sassc'
end

desc "Run all tests"
task test: 'compile:libsass' do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
