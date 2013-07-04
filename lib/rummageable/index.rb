require 'json'

class Rummageable::Index
  def initialize(url, name, options = {})
    @rummager_url = url
    @name = name
    @logger = options[:logger] || NullLogger.instance
    @batch_size = options.fetch(:batch_size, 20)
    @timeout = options.fetch(:timeout, 2)
    @attempts = options.fetch(:attempts, 3)
  end

  def add(entry)
    repeatedly { make_request(:post, documents_url, MultiJson.encode([entry])) }
  end

  def add_batch(entries)
    entries.each_slice(@batch_size) do |data|
      repeatedly do
        make_request(:post, documents_url, MultiJson.encode(data))
      end
    end
  end

  def delete(link)
    repeatedly do
      make_request(:delete, documents_url(link: link))
    end
  end

  def delete_all
    repeatedly do
      make_request(:delete, documents_url + '?delete_all=1')
    end
  end

  private
    def repeatedly(&block)
      @attempts.times do |i|
        begin
          return yield
        rescue RestClient::RequestFailed => e
          @logger.warn e
          raise if (this_attempt = i + 1) == @attempts
          @logger.info 'Retrying...'
          sleep(@timeout) if @timeout
        end
      end
    end

    def log_request(method, url, payload = nil)
      @logger.info("#{method.upcase} to #{url}")
    end

    def log_response(method, url, call_time, response)
      time = sprintf('%.03f', call_time)
      status = JSON.parse(response).fetch('status', 'UNKNOWN')
      @logger.info("#{method.upcase} #{url} - time: #{time}s, status: #{status}")
    end

    def make_request(method, *args)
      response = nil
      log_request(method, *args)
      call_time = Benchmark.realtime do
        response = RestClient.send(method, *args, content_type: :json, accept: :json)
      end
      log_response(method, args.first, call_time, response)
      response
    end

    def documents_url(options = {})
      parts = [@rummager_url, @name, 'documents']
      parts << CGI.escape(options[:link]) if options[:link]
      parts.join('/')
    end
end
