require "rest_client"
require "json"
require "plek"

module Rummageable

  InvalidDocument = Class.new(RuntimeError)

  # documents must be either a hash (for one document) or an array of hashes
  # (for multiple documents)
  #
  def index(documents)
    documents = [documents].flatten
    documents.each do |document|
      validate_structure document
    end
    url = Plek.current.find("search") + "/documents"
    body = JSON.dump(documents)
    RestClient.post url, body, content_type: :json, accept: :json
  end

  VALID_KEYS = [
    %w[title],
    %w[description],
    %w[format],
    %w[link],
    %w[indexable_content],
    %w[additional_links title],
    %w[additional_links link],
  ]

  def validate_structure(hash, parents=[])
    hash.each do |key, value|
      full_key = parents + [key]
      case value
      when Array
        value.each do |el|
          validate_structure el, full_key
        end
      when Hash
        validate_structure value, full_key
      else
        raise InvalidDocument unless VALID_KEYS.include?(full_key)
      end
    end
  end

  extend self
end
