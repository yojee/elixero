defmodule EliXero.Config do
  defstruct consumer_key: nil, consumer_secret: nil, app_type: :private, private_key_path: nil, webhook_key: nil, callback_url: nil
end

defmodule EliXero.Utils.Oauth do
  def create_auth_header(%EliXero.Config{} = config, method, url, additional_params, token) do
    {base_string, oauth_params} = create_oauth_context(config, method, url, additional_params)

    signature = sign(config, base_string, token)

    "OAuth oauth_signature=\"" <>
      signature <> "\", " <> EliXero.Utils.Helpers.join_params_keyword(oauth_params, :auth_header)
  end

  def create_auth_header(%EliXero.Config{} = config, method, url, additional_params) do
    {base_string, oauth_params} = create_oauth_context(config, method, url, additional_params)

    signature = sign(config, base_string)

    "OAuth oauth_signature=\"" <>
      signature <> "\", " <> EliXero.Utils.Helpers.join_params_keyword(oauth_params, :auth_header)
  end

  defp create_oauth_context(config, method, url, additional_params) do
    timestamp =
      :erlang.float_to_binary(Float.floor(:os.system_time(:milli_seconds) / 1000), [
        {:decimals, 0}
      ])

    oauth_signing_params = [
      oauth_consumer_key: config.consumer_key,
      oauth_nonce: EliXero.Utils.Helpers.random_string(10),
      oauth_signature_method: signature_method(config),
      oauth_version: "1.0",
      oauth_timestamp: timestamp
    ]

    params = additional_params ++ oauth_signing_params

    uri_parts = String.split(url, "?")
    url = Enum.at(uri_parts, 0)

    params_with_extras =
      if length(uri_parts) > 1 do
        query_params =
          Enum.at(uri_parts, 1)
          |> URI.decode_query()
          |> Enum.map(fn {key, value} ->
            {String.to_atom(key), URI.encode_www_form(value) |> String.replace("+", "%20")}
          end)

        params ++ query_params
      else
        params
      end

    params_with_extras = Enum.sort(params_with_extras)

    base_string =
      method <>
        "&" <>
        URI.encode_www_form(url) <>
        "&" <>
        URI.encode_www_form(
          EliXero.Utils.Helpers.join_params_keyword(params_with_extras, :base_string)
        )

    {base_string, params}
  end

  defp sign(config, base_string) do
    rsa_sha1_sign(config, base_string)
  end

  defp sign(config, base_string, token) do
    hmac_sha1_sign(config, base_string, token)
  end

  defp signature_method(config) do
    case(config.app_type) do
      :private -> "RSA-SHA1"
      :public -> "HMAC-SHA1"
      :partner -> "RSA-SHA1"
    end
  end

  defp rsa_sha1_sign(config, base_string) do
    hashed = :crypto.hash(:sha, base_string)

    {:ok, body} = File.read(config.private_key_path)

    [decoded_key] = :public_key.pem_decode(body)
    key = :public_key.pem_entry_decode(decoded_key)
    signed = :public_key.encrypt_private(hashed, key)
    URI.encode(Base.encode64(signed), &URI.char_unreserved?(&1))
  end

  defp hmac_sha1_sign(config, base_string, token) do
    key =
      case(token) do
        nil -> config.consumer_secret <> "&"
        _ -> config.consumer_secret <> "&" <> token["oauth_token_secret"]
      end

    signed = :crypto.hmac(:sha, key, base_string)
    URI.encode(Base.encode64(signed), &URI.char_unreserved?(&1))
  end
end
