require 'test_helper'

class ExceptionLoggerTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ExceptionLogger
  end
end
