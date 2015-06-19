namespace :libsass do
  desc "Compile libsass"
  task compile: "ext/libsass/lib/libsass.so"

  file "ext/libsass/.git" do
    sh "git submodule update --init"
  end

  file "ext/libsass/lib/libsass.so" => "ext/libsass/.git" do
    libsass_path = ""
    if Dir.pwd.end_with?('/ext')
      libsass_path = "libsass"
    else
      libsass_path = "ext/libsass"
    end

    cd libsass_path do
      sh 'make lib/libsass.so LDFLAGS="-Wall -O2"'
    end
  end
end
