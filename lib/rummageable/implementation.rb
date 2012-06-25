module Rummageable
  class Implementation
    def index(documents)
      documents = [documents].flatten
      documents.each do |document|
        validate_structure document
      end
      url = Rummageable.rummager_host + Rummageable.path_prefix + "/documents"
      0.step(documents.length - 1, CHUNK_SIZE).each do |i|
        body = JSON.dump(documents[i, CHUNK_SIZE])
        RestClient.post url, body, content_type: :json, accept: :json
      end
    end

    def delete(link)
      RestClient.delete url_for(link), content_type: :json, accept: :json
    end

    def commit
      url = Rummageable.rummager_host + Rummageable.path_prefix + "/commit"
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
    def url_for(link)
      [
        Rummageable.rummager_host, Rummageable.path_prefix,
        "/documents/", CGI.escape(link)
      ].join("")
    end
  end
end
