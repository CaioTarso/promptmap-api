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
    assert_not response.parsed_body["data"].first.key?("comments")
  end

  test "should get current user prompts" do
    get api_v1_my_prompts_path,
        headers: { "Authorization" => @token },
        as: :json

    assert_response :ok
    assert_equal [ prompts(:one).id ], response.parsed_body["data"].map { |prompt| prompt["id"] }
    assert_not response.parsed_body["data"].first.key?("comments")
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
    assert_nil response.parsed_body["thumbnail_url"]
  end

  test "should create prompt with top-level image upload" do
    image = fixture_file_upload("test-image.png", "image/png")

    assert_difference("Prompt.count", 1) do
      post api_v1_prompts_path,
           params: {
             prompt: {
               title: "Prompt com imagem",
               description: "Descricao do prompt",
               content: "Conteudo do prompt",
               prompt_type: "image"
             },
             image: image
           },
           headers: { "Authorization" => @token }
    end

    assert_response :created
    assert_equal 1, Prompt.last.images.count
    assert_equal 1, response.parsed_body["image_urls"].count
    assert_equal response.parsed_body["image_urls"].first, response.parsed_body["thumbnail_url"]
  end

  test "should create prompt with nested images upload" do
    image = fixture_file_upload("test-image.png", "image/png")

    assert_difference("Prompt.count", 1) do
      post api_v1_prompts_path,
           params: {
             prompt: {
               title: "Prompt com imagens",
               description: "Descricao do prompt",
               content: "Conteudo do prompt",
               prompt_type: "image",
               images: [ image ]
             }
           },
           headers: { "Authorization" => @token }
    end

    assert_response :created
    assert_equal 1, Prompt.last.images.count
    assert_equal 1, response.parsed_body["image_urls"].count
    assert_equal response.parsed_body["image_urls"].first, response.parsed_body["thumbnail_url"]
  end

  test "should create prompt with tags" do
    Tag.create!(name: "rails")

    assert_difference("Prompt.count", 1) do
      assert_difference("Tag.count", 1) do
        post api_v1_prompts_path,
             params: {
               prompt: {
                 title: "Prompt com tags",
                 description: "Descricao do prompt",
                 content: "Conteudo do prompt",
                 prompt_type: "document",
                 tag_names: [ "Rails", "AI", "ai", " " ]
               }
             },
             headers: { "Authorization" => @token },
             as: :json
      end
    end

    assert_response :created
    assert_equal [ "ai", "rails" ], response.parsed_body["tags"].map { |tag| tag["name"] }.sort
  end

  test "should replace prompt tags on update" do
    @prompt.tags = [ tags(:one) ]

    patch api_v1_prompt_path(@prompt),
          params: {
            prompt: {
              tag_names: [ "Ruby", "API" ]
            }
          },
          headers: { "Authorization" => @token },
          as: :json

    assert_response :ok
    assert_equal [ "api", "ruby" ], response.parsed_body["tags"].map { |tag| tag["name"] }.sort
  end
end
