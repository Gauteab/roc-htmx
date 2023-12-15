interface Pages.Packages exposes [render] imports [
        html.Html.{
            element,
            text,
            div,
            body,
        },
        html.Attribute,
        htmx.Hx,
        Database.{ Package },
        pf.Task.{ Task },
    ]

render : List Package -> Html.Node
render = \packages ->
    renderedPackages = List.map packages \{ name, author } -> div [] [text "\(name) by \(author)"]
    div [] renderedPackages
