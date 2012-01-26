require "rest_client"
require "json"
require "plek"

require "rummageable/implementation"
require "rummageable/fake"

module Rummageable

  InvalidDocument = Class.new(RuntimeError)
  CHUNK_SIZE = 20

  attr_writer :rummager_service_name
  def rummager_service_name
    @rummager_service_name || "search"
  end

  attr_writer :rummager_host
  def rummager_host
    @rummager_host || Plek.current.find(rummager_service_name)
  end

  attr_writer :path_prefix
  def path_prefix
    @path_prefix || ""
  end

  attr_writer :implementation
  def implementation
    @implementation ||= Implementation.new
  end

  # documents must be either a hash (for one document) or an array of hashes
  # (for multiple documents)
  #
  def index(documents)
    implementation.index(documents)
  end

  def delete(link)
    implementation.delete(link)
  end

  def commit
    implementation.commit
  end

  VALID_KEYS = [
    %w[title],
    %w[description],
    %w[format],
    %w[section],
    %w[subsection],
    %w[link],
    %w[indexable_content],
    %w[additional_links title],
    %w[additional_links link],
    %w[additional_links link_order],
  ]

  def validate_structure(hash, parents=[])
    implementation.validate_structure(hash, parents)
  end

  extend self
end
