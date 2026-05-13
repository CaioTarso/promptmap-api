require "test_helper"

class ApiV1CommentLikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @comment = Comment.create!(
      content: "Comentario para curtir",
      user: users(:two),
      prompt: prompts(:one)
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

  test "should like comment" do
    assert_difference("CommentLike.count", 1) do
      post api_v1_comment_like_path(@comment),
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :created
    assert_equal "Comment liked successfully", response.parsed_body["message"]
    assert_equal @comment.id, response.parsed_body["comment_id"]
    assert_equal 1, response.parsed_body["comment_likes_count"]
  end

  test "should not duplicate comment like" do
    CommentLike.create!(user: @user, comment: @comment)

    assert_no_difference("CommentLike.count") do
      post api_v1_comment_like_path(@comment),
           headers: { "Authorization" => @token },
           as: :json
    end

    assert_response :ok
    assert_equal "Comment already liked", response.parsed_body["message"]
    assert_equal 1, response.parsed_body["comment_likes_count"]
  end

  test "should unlike comment" do
    CommentLike.create!(user: @user, comment: @comment)

    assert_difference("CommentLike.count", -1) do
      delete api_v1_comment_like_path(@comment),
             headers: { "Authorization" => @token },
             as: :json
    end

    assert_response :ok
    assert_equal "Comment unliked successfully", response.parsed_body["message"]
    assert_equal 0, response.parsed_body["comment_likes_count"]
  end

  test "should return not found when unliking comment without like" do
    assert_no_difference("CommentLike.count") do
      delete api_v1_comment_like_path(@comment),
             headers: { "Authorization" => @token },
             as: :json
    end

    assert_response :not_found
    assert_equal "Comment like not found", response.parsed_body["error"]
  end
end
