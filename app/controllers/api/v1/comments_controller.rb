class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @prompt = Prompt.find(params[:prompt_id])
    @comments = @prompt.comments.includes(:replies).where(parent_id: nil)
    render json: @comments, include: comment_includes
  end

  def show
    @comment = Comment.find(params[:id])
    render json: @comment, include: comment_includes
  end

  def create
    @prompt = Prompt.find(params[:prompt_id])
    @comment = current_user.comments.build(comment_params)
    @comment.prompt = @prompt

    if @comment.save
      render json: @comment, include: comment_includes, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    @comment = current_user.comments.find(params[:id])

    if @comment.update(comment_params)
      render json: @comment, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy
    render json: { message: "Comment deleted successfully" }, status: :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def comment_includes
    {
      replies: {
        only: [ :id, :content, :user_id, :prompt_id, :parent_id, :comment_likes_count, :created_at, :updated_at ]
      }
    }
  end
end
