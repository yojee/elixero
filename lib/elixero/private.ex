defmodule EliXero.Private do

  def find(config, access_token, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.Oauth.create_auth_header(config, "GET", url, [oauth_token: access_token["oauth_token"]])
    EliXero.Utils.Http.get(config, url, header)
  end

  def find(config, access_token, resource, api_type, query_filters, extra_headers) do
    url = EliXero.Utils.Urls.api(resource, api_type) |> EliXero.Utils.Urls.append_query_filters(query_filters)

    header = EliXero.Utils.Oauth.create_auth_header(config, "GET", url, [oauth_token: access_token["oauth_token"]])
    EliXero.Utils.Http.get(config, url, header, extra_headers)
  end

  def create(config, access_token, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "PUT"
      end

    header = EliXero.Utils.Oauth.create_auth_header(config, method, url, [oauth_token: access_token["oauth_token"]])

    case(method) do
      "PUT" -> EliXero.Utils.Http.put(config, url, header, data_map)
    end
  end

  def update(config, access_token, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "POST"
      end

    header = EliXero.Utils.Oauth.create_auth_header(config, method, url, [oauth_token: access_token["oauth_token"]])

    case(method) do
      "POST" -> EliXero.Utils.Http.post(config, url, header, data_map)
    end
  end

  def delete(config, access_token, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.Oauth.create_auth_header(config, "DELETE", url, [oauth_token: access_token["oauth_token"]])

    EliXero.Utils.Http.delete(config, url, header)
  end

  def upload_multipart(config, access_token, resource, api_type, path_to_file, name) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.Oauth.create_auth_header(config, "POST", url, [oauth_token: access_token["oauth_token"]])

    EliXero.Utils.Http.post_multipart(config, url, header, path_to_file, name)
  end

  def upload_attachment(config, access_token, resource, api_type, path_to_file, filename, include_online) do
    url = EliXero.Utils.Urls.api(resource, api_type)
    url_for_signing = url <> "/" <> String.replace(filename, " ", "%20") <> "?includeonline=" <> ( if include_online, do: "true", else: "false") # Spaces must be %20 not +
    header = EliXero.Utils.Oauth.create_auth_header(config, "POST", url_for_signing, [oauth_token: access_token["oauth_token"]])

    url = url <> "/" <> URI.encode(filename, &URI.char_unreserved?(&1)) <> "?includeonline=" <> ( if include_online, do: "true", else: "false")
    EliXero.Utils.Http.post_file(config, url, header, path_to_file)
  end
end
