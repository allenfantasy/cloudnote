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

  def show
    @note = Note.find(params[:id])
  end

  # API
  def create
    @note = Note.new(params.require(:note).permit(:body))
    flash[:notice] = 'Note was successfully created!' if @note.save
    respond_with(@note)
  end

  def sync
    # TODO: check token

    logger.info "REQUEST IN >>>"
    logger.info JSON.parse(params['_json'])

    return_notes = []
    notes = params['_json']

    ids = []

    notes.each do |note|
      if note['id']
        begin
          n = Note.find(note['id'].to_i)
          ids << n.id

          # compare timestamp
          if note['timestamp'] >= n.timestamp
            # TODO: LOCK?
            n.update_attributes(body: note['body'], timestamp: note['timestamp'])
          else
            return_notes << n.jsonize(type: 0)
          end
        rescue ActiveRecord::RecordNotFound
          # cannot find the note, delete
          h = {
            id: note['id'],
            body: note['body'],
            timestamp: note['timestamp'],
            type: 3
          }
          return_notes << h.to_json
        end
      else
        n = Note.new(note)
        return_notes << n.jsonize(type: 2) if n.save
      end
    end

    # new notes from other devices
    newNotes = Note.where("id NOT IN(?)", ids)
    newNotes.each do |note|
      return_notes << note.jsonize(type: 1)
    end

    logger.info "<<< RESPONSE OUT"
    logger.info return_notes

    render json: return_notes.to_json
  end

end
