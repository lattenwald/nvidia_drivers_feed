defmodule NvidiaDriversFeed.Feed do
  require Logger

  @base "https://www.nvidia.com"

  def fetch do
    url = "https://www.nvidia.com/bin/nvidiaGDC/servlet/article.json?locale=en_US&region=us&limit=30&type=both&tag=drivers&offset=0"
    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, [%{"articlePagesList" => articles}]} <- Poison.decode(body)
    do
      items = articles |> Enum.map(&article_to_xml_structure/1)

      feed = {:rss, %{version: "2.0"}, [
        {:channel, nil, [
          {:title, nil, "NVIDIA drivers feed"},
          {:description, nil, "Feed generated from scraped JSON by tag=drivers"},
          {:link, nil, "https://www.nvidia.com/en-us/geforce/tags/?tag=drivers"},
        ] ++ items}
      ]}

      feed |> XmlBuilder.document |> XmlBuilder.generate
    else
      {:ok, %{status_code: 200, body: body}} ->
        {:content_error, body}
      {:ok, %{status_code: error_code}} ->
        {:error, {:http_error, error_code}}
      other = {:error, _} ->
        other
    end
  end

  defp article_to_xml_structure(json) do
    %{"articleTitle" => title,
      "authorName" => author,
      "articleDate" => date,
      "articleShortDescription" => description,
      "articlePath" => url,
      "tagsList" => tags } =  json
    image = with %{"featureImage" => image_url} <- json,
         [image_type] <- Regex.run(~r/\.([^\.]+)$/, image_url, capture: :all_but_first) do
      {:enclosure, %{url: "#{@base}#{image_url}", type: "image/#{image_type}"}, nil}
    else
      _ -> []
    end
    categories = tags |> Enum.map(fn %{"tagTitle" => tag_title} -> {:category, nil, tag_title} end)
    {:item, nil, [
      {:title, nil, title},
      {:link, nil, url},
      {:description, nil, description},
      {:author, nil, author},
      {:pubData, nil, date},
      image
    ] ++ categories }
  end

end
