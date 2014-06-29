require 'base64'
require 'openssl'

class NotesController < ApplicationController
  TOKEN = "cloudnote"

  respond_to :html, :json

  #before_action :check_signature
  before_action :validate_params, only: [:sync]

  def index
    @notes = Note.all

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

  # DELETE /notes/:id
  def delete
    @note = Note.find(params[:id])
    if @note.destroy
      render json: { code: 200, id: params[:id], message: 'delete success.' }.to_json
    else
      render json: { code: 400, id: params[:id], message: 'something fucked up' }.to_json
    end
  end

  def sync
    logger.info "REQUEST IN >>>"
    logger.info params['_json']

    return_notes = []
    notes = @data

    @data.each do |d, index|
      puts "Class: #{d.class}"
      puts "Data: #{d}"
      puts "ID: #{d['id']}"
      puts "Body: #{d['body']}"
      puts "Timestamp: #{d['timestamp']}"
    end

    ids = []

    notes.each do |note|
      if note['id']
        puts "id: #{note['id']}"
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
          return_notes << h
        end
      else
        puts "creating new note: #{note['timestamp']}"
        n = Note.new(note)
        if n.save
          return_notes << n.jsonize(type: 2)
          ids << n.id
        end
      end
    end

    # new notes from other devices
    newNotes = ids.empty? ? Note.all : Note.where("id NOT IN(?)", ids)
    newNotes.each do |note|
      return_notes << note.jsonize(type: 1)
    end

    logger.info "<<< RESPONSE OUT"
    logger.info return_notes

    render json: return_notes.to_json
  end

  private

  def check_signature
    signature, nonce, timestamp = request.headers["Signature"], request.headers["Nonce"], request.headers["Timestamp"]

    if [signature, nonce, timestamp].include?(nil) || sign(TOKEN, nonce, timestamp.to_s) != signature
      render json: { code: 401, message: 'authentication failed' }
    end
  end

  def validate_params
    data = params['_json'] || params["(null)"] ||JSON.parse(request.body.string)
    valid_attrs = Note.attribute_names.delete_if { |value| %w[id created_at updated_at].include?(value) }

    if !data.is_a?(Array)
      render json: { code: 400, message: 'invalid request: please send an array' }.to_json
    else
      @data = data
      data.each do |item|
        valid_attrs.each do |key|
          render json: { code: 400, message: "missing #{key}" }.to_json if !item.keys.include?(key)
          return # prevent double render error
        end
      end
    end
  end

  def sign(*data)
    Base64.encode64(OpenSSL::Digest.new('md5', data.sort.join("")).to_s)
  end

end
