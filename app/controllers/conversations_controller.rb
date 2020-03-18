class ConversationsController < ApplicationController
  def index
    # @users = User.all
    if current_user.developer
      @conversations = Conversation.where(developer: current_user.developer).sort_by { |conversation| conversation.messages.last.created_at}.reverse!
    else
      @conversations = Conversation.where(company: current_user.company).sort_by { |conversation| conversation.messages.last.created_at}.reverse!
    end
    @message = Message.new
  end

  def create
    if Conversation.between(params[:developer_id], params[:company_id]).present?
      @conversation = Conversation.between(params[:developer_id], params[:company_id]).first
    else
      @conversation = Conversation.create(conversation_params)
    end
    redirect_to new_conversation_message_path(@conversation)
  end

  private

  def conversation_params
    params.permit(:company_id, :developer_id)
  end

end
