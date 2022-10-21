# frozen_string_literal: true

require 'sassc'

require 'fileutils'
require 'minitest/autorun'
require 'minitest/around/unit'

module FixtureHelper
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

  def fixture(path)
    File.read(fixture_path(path))
  end

  def fixture_path(path)
    if path.match(FIXTURE_ROOT)
      path
    else
      File.join(FIXTURE_ROOT, path)
    end
  end
end

module TempFileTest
  def around
    pwd = Dir.pwd
    tmpdir = Dir.mktmpdir
    Dir.chdir tmpdir
    yield
  ensure
    Dir.chdir pwd
    FileUtils.rm_rf(tmpdir)
  end

  def temp_file(filename, contents)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write(filename, contents)
  end

  def temp_dir(directory)
    FileUtils.mkdir_p(directory)
  end
end
