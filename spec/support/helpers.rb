def test_request(method, path, headers, body)
  request = if ActionDispatch::TestRequest.respond_to?(:create)
              ActionDispatch::TestRequest.create
            else
              ActionDispatch::TestRequest.new
            end

  request.request_method = method
  request.path = path
  request.headers.merge!(headers)
  request.env['RAW_POST_DATA'] = body.dup
  request
end
