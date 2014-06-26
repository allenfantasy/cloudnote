class Note < ActiveRecord::Base
  belongs_to :user, inverse_of: :notes

  def jsonize(options = {})
    attributes.slice('id', 'body', 'timestamp').merge("type" => options[:type]).to_json
  end
end
