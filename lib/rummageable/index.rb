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
    repeatedly { post_batch([entry]) }
  end

  def add_batch(entries)
    entries.each_slice(@batch_size) do |batch|
      repeatedly { post_batch(batch) }
    end
  end

  private
    def post_batch(batch)
      response = nil
      @logger.info "Posting #{batch.size} document(s) to #{rummager_endpoint}"
      @logger.debug batch.map { |entry| entry['link'] }.join(", ")
      call_time = Benchmark.realtime do
        json = MultiJson.encode(batch)
        response = RestClient.post(rummager_endpoint, json, content_type: :json, accept: :json)
      end
      @logger.debug "Response: #{response} took (#{call_time})"
      response
    end

    def rummager_endpoint
      "#{@rummager_url}/#{@name}/documents"
    end

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
end
