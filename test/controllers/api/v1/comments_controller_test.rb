require "test_helper"

class ApiV1CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @prompt = prompts(:one)
    @comment = comments(:one)

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

  test "should get prompt comments" do
    get api_v1_prompt_comments_path(@prompt),
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal [ @comment.id ], response.parsed_body.map { |comment| comment["id"] }
  end

  test "should get show" do
    get api_v1_comment_path(@comment),
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal @comment.id, response.parsed_body["id"]
  end

  test "should create comment for prompt" do
    assert_difference("Comment.count", 1) do
      post api_v1_prompt_comments_path(@prompt),
           params: {
             comment: {
               content: "Novo comentario"
             }
           },
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :created
    assert_equal "Novo comentario", response.parsed_body["content"]
    assert_equal @user.id, response.parsed_body["user_id"]
    assert_equal @prompt.id, response.parsed_body["prompt_id"]
  end

  test "should update own comment" do
    patch api_v1_comment_path(@comment),
          params: {
            comment: {
              content: "Comentario atualizado"
            }
          },
          headers: { "Authorization" => @token },
          as: :json

    assert_response :ok
    assert_equal "Comentario atualizado", response.parsed_body["content"]
  end

  test "should destroy own comment" do
    assert_difference("Comment.count", -1) do
      delete api_v1_comment_path(@comment),
             headers: { "Authorization" => @token },
             as: :json
    end

    assert_response :ok
    assert_equal "Comment deleted successfully", response.parsed_body["message"]
  end
end
