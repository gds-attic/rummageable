module Rummageable
  class Implementation
    # Byte-to-byte read timeout.
    TIMEOUT      = 5.0

    # TCP connect() timeout.
    OPEN_TIMEOUT = 1.0

    def index(documents, index_name)
      documents = documents.is_a?(Hash) ? [documents] : documents
      url = Rummageable.rummager_host + index_name + "/documents"
      documents.each_slice(CHUNK_SIZE).each do |slice|
        slice.each do |document|
          validate_structure document
        end
        body = MultiJson.encode(slice)
        request(:post, url, body, json_headers())
      end
    end

    def amend(link, amendments, index_name)
      validate_structure amendments
      request(:post, url_for(link, index_name), amendments)
    end

    def delete(link, index_name)
      request(:delete, url_for(link, index_name), json_headers())
    end

    def delete_all(index_name)
      url = Rummageable.rummager_host + index_name + "/documents?delete_all=1"
      request(:delete, url, json_headers())
    end

    def commit(index_name)
      url = Rummageable.rummager_host + index_name + "/commit"
      request(:post, url, {})
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

    def request(method, url, payload = nil, headers = nil)
      args = {
        method:       method,
        url:          url,
        timeout:      TIMEOUT,
        open_timeout: OPEN_TIMEOUT,
      }
      args[:payload] = payload if payload
      args[:headers] = headers if headers

      RestClient::Request.execute(args)
    end

    def json_headers
      { accept: :json, content_type: :json, }
    end

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
