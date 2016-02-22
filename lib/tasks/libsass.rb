namespace :libsass do
  desc "Compile libsass"
  task :compile do
    if Dir.pwd.end_with?('/ext')
      libsass_path = "libsass"
    else
      libsass_path = "ext/libsass"
    end

    cd libsass_path do
      Rake::Task["lib/libsass.so"].invoke
    end
  end

  file "Makefile" do
    sh "git submodule update --init"
  end

  file "lib/libsass.so" => "Makefile" do
    make_program = ENV['MAKE']
    make_program ||= case RUBY_PLATFORM
                     when /mswin/
                       'nmake'
                     when /(bsd|solaris)/
                       'gmake'
                     else
                       'make'
                     end
    sh "#{make_program} lib/libsass.so"
  end
end
