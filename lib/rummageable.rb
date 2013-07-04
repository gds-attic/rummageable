require 'rest_client'
require 'multi_json'
require 'null_logger'
require 'plek'

require 'rummageable/implementation'
require 'rummageable/index'
require 'rummageable/fake'

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

  attr_writer :default_index
  def default_index
    @default_index || ""
  end

  attr_writer :implementation
  def implementation
    @implementation ||= Implementation.new
  end

  # documents must be either a hash (for one document) or an array of hashes
  # (for multiple documents)
  #
  def index(documents, index_name = default_index)
    implementation.index(documents, index_name)
  end

  def delete(link, index_name = default_index)
    implementation.delete(link, index_name)
  end

  def delete_all(index_name = default_index)
    implementation.delete_all(index_name)
  end

  def amend(link, amendments, index_name = default_index)
    implementation.amend(link, amendments, index_name)
  end

  def commit(index_name = default_index)
    implementation.commit(index_name)
  end

  VALID_KEYS = [
    %w[title],
    %w[description],
    %w[format],
    %w[section],
    %w[subsection],
    %w[subsubsection],
    %w[link],
    %w[indexable_content],
    %w[boost_phrases],
    %w[link_order],
  ]

  def validate_structure(hash, parents=[])
    implementation.validate_structure(hash, parents)
  end

  extend self
end
