defmodule EliXero do
  def get_request_token(%EliXero.Config{} = config) do
    response =
      case(config.app_type) do
        :private -> raise "Getting a request token is not applicable with Private applications."
        :public -> EliXero.Public.get_request_token(config)
        :partner -> EliXero.Partner.get_request_token(config)
      end

    case response do
      %{"http_status_code" => 200}  -> Map.merge(response, %{"auth_url" => EliXero.Utils.Urls.authorise(response["oauth_token"])})
      _                             -> response
    end
  end

  def create_client(%EliXero.Config{} = config) do
    case(config.app_type) do
      :private -> %EliXero.Client{config: config, app_type: :private, access_token: %{"oauth_token" => config.consumer_key}}
      :public -> raise "Nope. Access token required"
      :partner -> raise "Nope. Access token required"
    end
  end

  def create_client(%EliXero.Config{} = config, request_token, verifier) do
    response =
      case(config.app_type) do
        :private -> raise "Approving an access token is not applicable with Private applications"
        :public -> EliXero.Public.approve_access_token(config, request_token, verifier)
        :partner -> EliXero.Partner.approve_access_token(config, request_token, verifier)
      end

    case response do
      %{"http_status_code" => 200}  -> create_client(config, response)
      _                             -> response
    end
  end

  def renew_client(client) do
    response =
      case(client.config.app_type) do
        :private -> raise "Renewing an access token is not applicable with Private applications"
        :public -> raise "Renewing an access token is not applicable with Public applications"
        :partner -> EliXero.Partner.renew_access_token(client.config, client.access_token)
      end

    case response do
      %{"http_status_code" => 200}  -> create_client(client.config, response)
      _                             -> response
    end
  end

  defp create_client(%EliXero.Config{} = config, access_token) do
    case(config.app_type) do
      :private -> raise "Nope. No need for access token"
      :public -> %EliXero.Client{config: config, app_type: :public, access_token: access_token}
      :partner -> %EliXero.Client{config: config, app_type: :partner, access_token: access_token}
    end
  end
end
