interface Pages.Hello exposes [html] imports [
        html.Html.{
            text,
            div,
            button,
        },
        html.Attribute,
        htmx.Hx,
    ]

html : Html.Node
html =
    div [Attribute.id "parent-div"] [
        button
            [
                Hx.post "/clicked",
                Hx.trigger "click",
                Hx.target "#parent-div",
                Hx.swap "outerHTML",
            ]
            [text "Click Me!"],
    ]

