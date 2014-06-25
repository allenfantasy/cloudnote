class NotesController < ApplicationController
  respond_to :html, :json

  def index
    @notes = Note.all
    # return json
    render json: @notes
  end

  def new
    @note = Note.new
  end

  # API
  def create
    @note = Note.new(params.require(:note).permit(:body))
    flash[:notice] = 'Note was successfully created!' if @note.save
    respond_with(@note)
  end

  def show
    @note = Note.find(params[:id])
  end

  def sync
    # accept json request:
    # [
    #   {
    #     id: 1,
    #     body: ... TODO: should we use body?
    #     updated_at: ...
    #   },
    #   {
      #     id: 3,
    #     body: ...
    #     updated_at: ...
    #   },
    #   { // new record
    #     body: ...
    #     updated_at: ...
    #   }
    # ]
    #
    # return json request
    #
  end

end
