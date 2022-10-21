# frozen_string_literal: true

require_relative 'test_helper'

module SassC
  class VendorTest < MiniTest::Test
    class PassthroughImporter < Importer
      def imports(path, _parent_path)
        Import.new(path)
      end
    end

    def test_import_vendor_path_works
      ENV.fetch('VENDOR_PATH', '').split(File::PATH_SEPARATOR).each do |path|
        expected = SassC::Engine.new("@import '#{URL.escape(path)}';").render
        actual = SassC::Engine.new("@import '#{URL.escape(path)}';", {
                                     importer: PassthroughImporter
                                   }).render
        assert_equal expected, actual
      end
    end
  end
end
