class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    prompt = Prompt.find(params[:prompt_id])

    comments = prompt.comments
                     .includes(
                       :user,
                       replies: :user
                     )
                     .where(parent_id: nil)

    render json: comments,
           each_serializer: CommentSerializer,
           current_user: current_user
  end

  def show
    comment = Comment.find(params[:id])

    render json: comment,
           serializer: CommentSerializer,
           current_user: current_user
  end

  def create
    prompt = Prompt.find(params[:prompt_id])

    comment = current_user.comments.build(comment_params)
    comment.prompt = prompt

    if comment.save
      render json: comment,
             serializer: CommentSerializer,
             current_user: current_user,
             status: :created
    else
      render json: { errors: comment.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    comment = current_user.comments.find(params[:id])

    if comment.update(comment_params)
      render json: comment,
             serializer: CommentSerializer,
             current_user: current_user,
             status: :ok
    else
      render json: { errors: comment.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    comment = current_user.comments.find(params[:id])

    comment.destroy

    render json: { message: "Comment deleted successfully" },
           status: :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
