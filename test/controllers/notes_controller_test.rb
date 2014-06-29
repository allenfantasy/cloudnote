require 'test_helper'
require 'base64'
require 'openssl'

TOKEN = 'cloudnote'
def sign(nonce, timestamp)
  Base64.encode64(OpenSSL::Digest.new('md5', [TOKEN, nonce, timestamp.to_s].sort.join("")).to_s)
end

def set_headers(request)
  nonce, timestamp = 'fuckers', Time.now.to_i
  request.headers['Nonce'] = nonce
  request.headers['Timestamp'] = timestamp
  request.headers['Signature'] = sign(nonce, timestamp)
  req_headers = {
    "Content-Type" => "application/json",
    "Accept" => "application/json"
  }
end

describe NotesController do
  describe "GET #index" do
    it "should return 401 when fail to auth" do
      get :index
      data = JSON.parse(@response.body)#.symbolize_keys
      assert_equal 401, data["code"]
    end

    it "should return all notes if headers are OK" do
      set_headers(@request)

      note1 = create(:note)
      note2 = create(:note)

      get :index
      data = JSON.parse(@response.body)
      assert_equal "application/json; charset=utf-8", @response.headers["Content-Type"]
      assert_equal 2, data.length
    end
  end

  describe "POST #sync" do
    it "should return 401 when fail to auth" do
      params = [
        { id: 1, body: 'Note A', timestamp: Time.now.to_i },
        { id: 2, body: 'Note B', timestamp: Time.now.to_i }
      ]

      post :sync, params.to_json

      data = JSON.parse(@response.body)
      assert_equal data["code"], 401
      assert_equal data["message"], "authentication failed"
    end

    it "should return err if not receiving an array" do
      set_headers(@request)

      params = { id: 1, body: 'fucker' }
      post :sync, params.to_json

      data = JSON.parse(@response.body)
      assert_equal data["code"], 400
      assert_equal data["message"], "invalid request: please send an array"
    end

    it "should return updated notes(type=0)" do
      set_headers(@request)

      note = create(:note)

      params = [
        { id: note.id, body: 'Lorem ipsum...updated', timestamp: (Time.now - 1.days).to_i.to_s }
      ]

      post :sync, params.to_json
      data = JSON.parse(@response.body)
      assert_equal data[0]["id"], note.id
      assert_equal data[0]["body"], note.body
      assert_equal data[0]["type"], 0
    end

    it "should return new notes from other devices(type=1)" do
      set_headers(@request)

      note = create(:note)
      post :sync, [].to_json

      data = JSON.parse(@response.body)
      assert_equal data[0]["id"], note.id
      assert_equal data[0]["body"], note.body
      assert_equal data[0]["type"], 1
    end

    it "should save new notes from client, and return them with their IDs(type=2)" do
      set_headers(@request)

      timestamp = Time.now.to_i.to_s
      params = [ { body: "New Note", timestamp: timestamp }] # no ID
      post :sync, params.to_json

      data = JSON.parse(@response.body)
      assert_equal data.length, 1
      assert_equal data[0]["body"], "New Note"
      assert_equal data[0]["timestamp"], timestamp
      assert_equal data[0]["type"], 2
    end

    it "should return notes need to be deleted(type=3)" do
      set_headers(@request)

      timestamp = Time.now.to_i.to_s
      mock_id = 0 - 1

      params = [ { id: mock_id, body: "Note to delete", timestamp: timestamp }] # no ID
      post :sync, params.to_json

      data = JSON.parse(@response.body)
      assert_equal data.length, 1
      assert_equal data[0]["id"], mock_id
      assert_equal data[0]["body"], "Note to delete"
      assert_equal data[0]["timestamp"], timestamp
      assert_equal data[0]["type"], 3
    end
  end
end
