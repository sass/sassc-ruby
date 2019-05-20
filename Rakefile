require 'bundler/gem_tasks'

task default: :test

require 'rake/extensiontask'
gem_spec = Gem::Specification.load("sassc.gemspec")
Rake::ExtensionTask.new('libsass', gem_spec) do |ext|
  ext.name = 'libsass'
  ext.ext_dir = 'ext'
  ext.lib_dir = 'lib/sassc'
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw32 x86-linux x86_64-linux]
  ext.cross_compiling do |spec|
    spec.files.reject! { |path| File.fnmatch?('ext/*', path) }
  end
end

desc 'Compile all native gems via rake-compiler-dock (Docker)'
task 'gem:native' do
  require 'rake_compiler_dock'
  RakeCompilerDock.sh "bundle && gem i rake --no-document && "\
                      "rake cross native gem MAKE='nice make -j`nproc`' "\
                      "RUBY_CC_VERSION=2.6.0:2.5.0:2.4.0:2.3.0"
end

desc "Run all tests"
task test: 'compile:libsass' do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
