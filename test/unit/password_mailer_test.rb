require 'test_helper'

class PasswordMailerTest < ActionMailer::TestCase
  test "reset_password" do
    @expected.subject = 'PasswordMailer#reset_password'
    @expected.body    = read_fixture('reset_password')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PasswordMailer.create_reset_password(@expected.date).encoded
  end

end
