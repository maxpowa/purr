require "json"
require "crouter"
require "logger"

# In the event you want to upload to an imgur-like api, change this.
IMGUR_UPLOAD_ENDPOINT = "https://api.imgur.com/3/upload"

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG

module Purr
  VERSION = "0.0.1"

  class ImgurResponseData
    JSON.mapping(
      id: String,
      size: Float32,
      deletehash: String,
      link: String
    )
  end

  class ImgurResponse
    JSON.mapping(
      data: ImgurResponseData,
      success: Bool,
      status: Int32
    )
  end

  class PurrHandler
    include HTTP::Handler

    def initialize(client_id : String)
      @client_id = client_id
    end

    def call(context)
      if (context.request.path === "/upload" || context.request.path === "/upload.php")
        files = [] of NamedTuple(name: String, url: String, size: Float32)
        HTTP::FormData.parse(context.request) do |part|
          if part.name == "files[]"
            temp_io = IO::Memory.new
            content_type = ""
            HTTP::FormData.build(temp_io, "purr-boundary") do |builder|
              builder.file("image", part.body, HTTP::FormData::FileMetadata.new(filename: part.filename))
              content_type = builder.content_type
            end
            temp_io.rewind

            response = HTTP::Client.post(
              IMGUR_UPLOAD_ENDPOINT,
              headers: HTTP::Headers{
                "User-agent"    => "purr #{VERSION}",
                "Authorization" => "Client-ID #{@client_id}",
                "Content-Type"  => content_type,
              },
              body: temp_io
            )

            if (response.success?)
              imgur_metadata = ImgurResponse.from_json(response.body).data
              LOG.info("#{part.filename} uploaded - #{imgur_metadata.link} / deletehash #{imgur_metadata.deletehash}")
              files << {name: part.filename.as(String), url: imgur_metadata.link, size: imgur_metadata.size}
            else
              LOG.info("#{part.filename} failed - #{response.body}")
            end
          end
        end

        case context.request.query_params["output"]?
        when "gyazo"
          context.response.content_type = "text/plain"
          files.map { |file| file[:url] }.join('\n', context.response)
        when "text"
          context.response.content_type = "text/plain"
          files.map { |file| file[:url] }.join('\n', context.response)
          context.response << '\n'
        else
          context.response.content_type = "application/json"
          {success: true, files: files}.to_json(context.response)
        end
      end
    end
  end

  def self.run_server(port : Int32, client_id : String)
    server = HTTP::Server.new(port, [
      HTTP::ErrorHandler.new,
      HTTP::LogHandler.new,
      PurrHandler.new(client_id),
    ])
    server.bind
    puts "Listening on http://localhost:#{server.port}"
    server.listen
  end
end
