class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)

    re = /@([0-9a-z_]{5,15})/i
    reply_user_unique_name = @micropost.content.match(re).to_s.downcase.delete("@")

    if reply_user_unique_name
      reply_user = User.find_by(unique_name: reply_user_unique_name)
      @micropost.in_reply_to = reply_user&.id if reply_user
    end

    if @micropost.save
      flash[:success] = t('microposts.create.success')
      redirect_to root_url
    else
      flash[:error] = t('microposts.create.error')
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t('microposts.destroy.success')
      redirect_back(fallback_location: root_url)
    else
      flash[:error] = t('microposts.destroy.error')
      render 'static_pages/home'
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
