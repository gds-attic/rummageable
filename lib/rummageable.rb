require "rest_client"
require "json"
require "plek"

module Rummageable

  InvalidDocument = Class.new(RuntimeError)
  CHUNK_SIZE = 20

  attr_writer :host
  def host
    @host || Plek.current.find("search")
  end

  # documents must be either a hash (for one document) or an array of hashes
  # (for multiple documents)
  #
  def index(documents)
    documents = [documents].flatten
    documents.each do |document|
      validate_structure document
    end
    url = host + "/documents"
    0.step(documents.length - 1, CHUNK_SIZE).each do |i|
      body = JSON.dump(documents[i, CHUNK_SIZE])
      RestClient.post url, body, content_type: :json, accept: :json
    end
  end

  def delete(link)
    url = host + "/documents/" + CGI.escape(link)
    RestClient.delete url, content_type: :json, accept: :json
  end

  VALID_KEYS = [
    %w[title],
    %w[description],
    %w[format],
    %w[section],
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
