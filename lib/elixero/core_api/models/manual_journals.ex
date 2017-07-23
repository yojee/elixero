defmodule EliXero.CoreApi.Models.ManualJournals do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Poison.Encoder, except: [:__meta__, :id]}

    schema "manualjournals" do
        embeds_many :ManualJournals, EliXero.CoreApi.Models.ManualJournals.ManualJournal
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:ManualJournals)
        |> apply_changes
    end
end