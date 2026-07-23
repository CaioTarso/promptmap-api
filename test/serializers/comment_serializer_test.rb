require "test_helper"

class CommentSerializerTest < ActiveSupport::TestCase
  test "serializes replies with the author user" do
    user = users(:one)
    prompt = prompts(:one)
    comment = comments(:one)

    reply = comment.replies.create!(
      content: "Reply content",
      user: user,
      prompt: prompt
    )

    payload = ActiveModelSerializers::SerializableResource.new(
      comment,
      serializer: CommentSerializer,
      current_user: user
    ).to_json

    payload = JSON.parse(payload)

    assert_equal user.id, payload.dig("replies", 0, "user", "id")
    assert_equal user.name, payload.dig("replies", 0, "user", "name")
    assert_equal reply.id, payload.dig("replies", 0, "id")
  end
end
