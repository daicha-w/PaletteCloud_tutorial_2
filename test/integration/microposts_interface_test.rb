require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,picture: picture } }
    end
    assert assigns(:micropost).picture?
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: I18n.t('microposts.micropost.delete')
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: I18n.t('microposts.micropost.delete'), count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} " + I18n.t('shared.user_info.micropost'), response.body
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 " + I18n.t('shared.user_info.micropost'), response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 " + I18n.t('shared.user_info.micropost'), response.body
  end

  test "reply should be shown only in feeds of the person who submitted it or the person to whom it was sent or users who follow the one who submitted it" do
    from_user   = users(:michael)
    to_user     = users(:archer)
    other_user1 = users(:lana)
    other_user2 = users(:john)
    unique_name = to_user.unique_name
    content = "@#{unique_name} reply test in integration test"
    log_in_as(from_user)
    post microposts_path, params: { micropost: { content: content } }
    micropost_id = from_user.microposts.first.id
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content
    log_in_as(to_user)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content
    log_in_as(other_user1)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content
    log_in_as(other_user2)
    get root_path
    assert_no_match "#micropost-#{micropost_id}", response.body
  end
end