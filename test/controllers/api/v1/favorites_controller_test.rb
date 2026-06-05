require "test_helper"

class ApiV1FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.favorites.destroy_all
    @prompt = Prompt.create!(
      title: "Prompt para favoritar",
      content: "Conteudo do prompt",
      prompt_type: "document",
      user: users(:two)
    )

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

  test "should get current user favorite prompts" do
    Favorite.create!(user: @user, prompt: @prompt)

    get api_v1_my_favorite_prompts_path,
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal [ @prompt.id ], response.parsed_body.map { |prompt| prompt["id"] }
  end

  test "should favorite prompt" do
    assert_difference("Favorite.count", 1) do
      post api_v1_prompt_favorite_path(@prompt),
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :created
    assert_equal "Prompt favorited successfully", response.parsed_body["message"]
    assert_equal @prompt.id, response.parsed_body["prompt_id"]
    assert_equal 1, response.parsed_body["favorites_count"]
  end

  test "should not duplicate prompt favorite" do
    Favorite.create!(user: @user, prompt: @prompt)

    assert_no_difference("Favorite.count") do
      post api_v1_prompt_favorite_path(@prompt),
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :ok
    assert_equal "Prompt already favorited", response.parsed_body["message"]
    assert_equal 1, response.parsed_body["favorites_count"]
  end

  test "should unfavorite prompt" do
    Favorite.create!(user: @user, prompt: @prompt)

    assert_difference("Favorite.count", -1) do
      delete api_v1_prompt_favorite_path(@prompt),
             headers: { "Authorization" => @token },
             as: :json
    end

    assert_response :ok
    assert_equal "Prompt unfavorited successfully", response.parsed_body["message"]
    assert_equal 0, response.parsed_body["favorites_count"]
  end

  test "should return not found when unfavoriting prompt without favorite" do
    assert_no_difference("Favorite.count") do
      delete api_v1_prompt_favorite_path(@prompt),
             headers: { "Authorization" => @token },
             as: :json
    end

    assert_response :not_found
    assert_equal "Favorite not found", response.parsed_body["error"]
  end
end
