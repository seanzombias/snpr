class SnpCommentsController < ApplicationController
  before_filter :require_user

  def new
		@snp_comment = SnpComment.new
		# current user is always stored in the method 'current_user',
		# not in the variable '@current_user'
		@title = "Add comment"

		respond_to do |format|
			format.html
			format.xml { render :xml => @snp }
		end
	end

	def create
		@snp_comment = SnpComment.new(params[:snp_comment])
		logger.debug @snp_comment
		if @snp_comment.comment_text.index("@") == nil
			@snp_comment.reply_to_id = -1
		else
			# find the comment this post links to
			# all comments
			@all_comments = Snp.find_by_id(@snp_comment.snp_id).snp_comments
			# user to which we're talking
			@referred_to = @snp_comment.comment_text.split()[0].chomp(":").gsub("@","")
			@referred_to_id = User.find_by_name(@referred_to).id
			@snp_comment.reply_to_id = @all_comments.find_by_user_id(@referred_to_id)
		end
		@snp_comment.user_id = current_user.id
		logger.debug current_user.inspect
		@snp_comment.snp_id = params[:snp_comment][:snp_id]
  		if @snp_comment.save
			redirect_to "/snps/"+Snp.find_by_id(@snp_comment.snp_id).id.to_s + "#comments", :notice => 'Comment succesfully created.'
		else
			render :action => "new"
  		end
  	end

end