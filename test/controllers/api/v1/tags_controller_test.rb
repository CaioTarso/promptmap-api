require "test_helper"

class ApiV1TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @tag = tags(:one)

    post user_session_path,
         params: {
           user: {
             email: @user.email,
             password: "password"
           }
         },
         as: :json

    @token = response.headers["Authorization"]
  end

  test "should get index" do
    get api_v1_tags_path,
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert response.parsed_body.any? { |tag| tag["id"] == @tag.id }
  end

  test "should get show" do
    get api_v1_tag_path(@tag),
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal @tag.id, response.parsed_body["id"]
  end
end
