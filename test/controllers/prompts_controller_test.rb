require "test_helper"

class ApiV1PromptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

    post user_session_path,
         params: {
           user: {
             email: @user.email,
             password: "password"
           }
         },
         as: :json

    @token = response.headers["Authorization"]
    @prompt = prompts(:one)
  end

  test "should get index" do
    get api_v1_prompts_path,
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_not response.parsed_body.first.key?("comments")
  end

  test "should get current user prompts" do
    get api_v1_my_prompts_path,
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal [ prompts(:one).id ], response.parsed_body.map { |prompt| prompt["id"] }
    assert_not response.parsed_body.first.key?("comments")
  end

  test "should create prompt" do
    assert_difference("Prompt.count", 1) do
      post api_v1_prompts_path,
           params: {
             prompt: {
               title: "Prompt de teste",
               description: "Descrição do prompt",
               content: "Conteúdo do prompt",
               prompt_type: "document"
             }
           },
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :created
    assert_equal "Prompt de teste", response.parsed_body["title"]
  end
end
