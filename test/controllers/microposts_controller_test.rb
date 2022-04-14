require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end

  test "user id should be set to in_reply_to when reply" do
    from_user = users(:michael)
    log_in_as(from_user)
    to_user = users(:archer)
    unique_name = to_user.unique_name
    content = "@#{unique_name} reply test"
    post microposts_path, params: { micropost: { content: content } }
    assert_equal to_user.id, Micropost.first.in_reply_to
  end
end