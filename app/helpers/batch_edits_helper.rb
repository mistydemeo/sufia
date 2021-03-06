# View Helpers for Hydra Batch Edit functionality
module BatchEditsHelper
  # Displays the delete button for batch editing
  def batch_delete
    render partial: '/batch_edits/delete_selected'
  end

  def render_check_all
    unless @disable_select_all || params[:controller].match("my/collections")
      render partial: 'batch_edits/check_all'
    end
  end
end
