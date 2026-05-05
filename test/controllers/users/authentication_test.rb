require "test_helper"

class Users::AuthenticationTest < ActionDispatch::IntegrationTest
  test "signs up and returns a jwt token" do
    post user_registration_path,
         params: {
           user: {
             name: "Jane Doe",
             email: "jane@example.com",
             password: "password",
             password_confirmation: "password"
           }
         },
         as: :json

    assert_response :created
    assert_match(/\ABearer /, response.headers["Authorization"])
    assert_equal "jane@example.com", response.parsed_body.dig("user", "email")
  end

  test "logs in and logs out with jwt" do
    post user_session_path,
         params: {
           user: {
             email: users(:one).email,
             password: "password"
           }
         },
         as: :json

    assert_response :ok
    token = response.headers["Authorization"]
    assert_match(/\ABearer /, token)

    delete destroy_user_session_path,
           headers: {
             "Authorization" => token
           },
           as: :json

    assert_response :ok
    assert_equal "Logged out successfully.", response.parsed_body["message"]
  end
end
