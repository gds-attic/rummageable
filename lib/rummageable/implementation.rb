module Rummageable
  class Implementation
    def index(documents, index_name)
      documents = [documents].flatten
      documents.each do |document|
        validate_structure document
      end
      url = Rummageable.rummager_host + index_name + "/documents"
      0.step(documents.length - 1, CHUNK_SIZE).each do |i|
        body = JSON.dump(documents[i, CHUNK_SIZE])
        RestClient.post url, body, content_type: :json, accept: :json
      end
    end

    def amend(link, amendments, index_name)
      validate_structure amendments
      RestClient.post url_for(link, index_name), amendments
    end

    def delete(link, index_name)
      RestClient.delete url_for(link, index_name), content_type: :json, accept: :json
    end

    def delete_all(index_name)
      url = Rummageable.rummager_host + index_name + "/documents?delete_all=1"
      RestClient.delete url, content_type: :json, accept: :json
    end

    def commit(index_name)
      url = Rummageable.rummager_host + index_name + "/commit"
      RestClient.post url, {}
    end

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

  private

    def url_components(index_name)
      [Rummageable.rummager_host, index_name, "/documents/"]
    end

    def url_for(link, index_name)
      (url_components(index_name) << CGI.escape(link)).join
    end

    def unescaped_url_for(link, index_name)
      (url_components(index_name) << link).join
    end
  end
end
