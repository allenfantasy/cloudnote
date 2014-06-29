require 'test_helper'
require 'base64'
require 'openssl'

TOKEN = 'cloudnote'
def sign(nonce, timestamp)
  Base64.encode64(OpenSSL::Digest.new('md5', [TOKEN, nonce, timestamp.to_s].sort.join("")).to_s)
end

def add_headers(request)
  nonce, timestamp = 'fuckers', Time.now.to_i
  request.headers['Nonce'] = nonce
  request.headers['Timestamp'] = timestamp
  request.headers['Signature'] = sign(nonce, timestamp)
end

describe NotesController do
  describe "GET #index" do
    it "should fail to auth when missing headers" do
      get :index
      data = JSON.parse(@response.body)#.symbolize_keys
      assert_equal 401, data["code"]
      assert_equal "application/json; charset=utf-8", @response.headers["Content-Type"]
    end

    it "should return all notes if headers are OK" do
      add_headers(@request)

      note1 = create(:note)
      note2 = create(:note)

      get :index
      data = JSON.parse(@response.body)
      assert_equal "application/json; charset=utf-8", @response.headers["Content-Type"]
      assert_equal 2, data.length
    end
  end

  describe "POST #sync" do
    it "should return 401 if auth failed" do
      req_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }

      params = [
        {
          id: 1,
          body: 'Note A',
          timestamp: Time.now.to_i
        },
        {
          id: 2,
          body: 'Note B',
          timestamp: Time.now.to_i
        }
      ]

      post :sync, params.to_json, req_headers
      data = JSON.parse(@response.body)
      #puts data
      assert_equal data["code"], 401
      assert_equal data["message"], "authentication failed"
    end

    it "should return err if not receiving an array" do
      add_headers(@request)

      req_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }

      params = {
        id: 1,
        body: 'fucker'
      }

      post :sync, params.to_json, req_headers
      data = JSON.parse(@response.body)
      assert_equal data["code"], 400
      assert_equal data["message"], "invalid request: please send an array"
    end

    it "should return updated notes(type=0)" do
      add_headers(@request)
      req_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }

      note = create(:note)

      params = [
        {
          id: note.id,
          body: 'Lorem ipsum...updated',
          timestamp: (Time.now - 1.days).to_i.to_s # String
        }
      ]

      post :sync, params.to_json, req_headers
      data = JSON.parse(@response.body)
      assert_equal data[0]["id"], note.id
      assert_equal data[0]["body"], note.body
      assert_equal data[0]["timestamp"], note.timestamp
    end

    it "should return new notes from other devices(type=1)" do
      skip("pending")
    end

    it "should save new notes from client, and return them with their IDs(type=2)" do
      skip("pending")
    end

    it "should return notes need to be deleted(type=3)" do
      skip("pending")
    end
  end
end
