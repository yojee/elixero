defmodule EliXero.FilesApi.Files do
  @resource "files"
  @api_type :files

  def upload(client, path_to_file, name) do
    case(client.config.app_type) do
      :private -> EliXero.Private.upload_multipart(client.config, client.access_token, @resource, @api_type, path_to_file, name)
      :public -> EliXero.Public.upload_multipart(client.config, client.access_token, @resource, @api_type, path_to_file, name)
      :partner -> EliXero.Partner.upload_multipart(client.config, client.access_token, @resource, @api_type, path_to_file, name)
    end
  end
end
