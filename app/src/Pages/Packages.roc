interface Pages.Packages exposes [html, render] imports [
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
    renderedPackages = List.map packages \{ name, author } ->
        Html.tr [] [Html.td [] [text name], Html.td [] [text author]]
    Html.tbody [Attribute.id "search-results"] renderedPackages

html = div [] [
    Html.h3 [] [
        Html.text "Search Packages",
        Html.span [Attribute.class "htmx-indicator"] [
            # Html.img [Attribute.src "/img/bars.svg"] [],
            Html.text "Searching...",
        ],
    ],
    Html.input
        [
            Attribute.class "form-control",
            Attribute.type "search",
            Attribute.name "search",
            Attribute.placeholder "Begin Typing To Search Packages...",
            Hx.post "/search",
            Hx.trigger "input changed delay:500ms, search",
            Hx.target "#search-results",
            Hx.swap "outerHTML",
            Hx.indicator ".htmx-indicator",
        ]
        [],
    Html.table [Attribute.class "table"] [
        Html.thead [] [
            Html.tr [] [
                Html.th [] [Html.text "Name"],
                Html.th [] [Html.text "Author"],
            ],
        ],
        Html.tbody [Attribute.id "search-results"] [],
    ],
]
