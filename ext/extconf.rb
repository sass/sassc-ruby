# frozen_string_literal: true

gem_root = File.expand_path('..', __dir__)
libsass_dir = File.join(gem_root, 'ext', 'libsass')

if !File.directory?(libsass_dir) ||
   # '.', '..', and possibly '.git' from a failed checkout:
   Dir.entries(libsass_dir).size <= 3
  Dir.chdir(gem_root) { system('git submodule update --init') } or
    fail 'Could not fetch libsass'
end

# Only needed because rake-compiler expects `.bundle` on macOS:
# https://github.com/rake-compiler/rake-compiler/blob/9f15620e7db145d11ae2fc4ba032367903f625e3/features/support/platform_extension_helpers.rb#L5
dl_ext = (RUBY_PLATFORM =~ /darwin/ ? 'bundle' : 'so')

File.write 'Makefile', <<-MAKEFILE
ifndef DESTDIR
	LIBSASS_OUT = #{gem_root}/lib/sassc/libsass.#{dl_ext}
else
	LIBSASS_OUT = $(DESTDIR)$(PREFIX)/libsass.#{dl_ext}
endif

SUB_DIR := #{libsass_dir}

libsass.#{dl_ext}:#{' clean' if ENV['CLEAN']}
	$(MAKE) -C '$(SUB_DIR)' lib/libsass.so
	cp '$(SUB_DIR)/lib/libsass.so' libsass.#{dl_ext}
	strip -x libsass.#{dl_ext}

install: libsass.#{dl_ext}
	cp libsass.#{dl_ext} '$(LIBSASS_OUT)'

clean:
	$(MAKE) -C '$(SUB_DIR)' clean
	rm -f '$(LIBSASS_OUT)' libsass.#{dl_ext}

.PHONY: clean install
MAKEFILE
