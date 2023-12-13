interface Index exposes [html] imports [html.Html.{
        element,
        text,
        div,
        body,
    }, html.Attribute.{
        charset,
        src,
        name,
        content,
        attribute,
        lang,
    }, htmx.Hx]

html =
    (element "html")
        [lang "en"]
        [
            (element "head") [] [
                (element "meta") [charset "UTF-8"] [],
                (element "meta")
                    [
                        name "viewport",
                        content "width=device-width, initial-scale=1.0",
                    ]
                    [],
                (element "script")
                    [
                        src "https://unpkg.com/htmx.org@1.9.9",
                        (attribute "integrity") "sha384-QFjmbokDn2DjBjq+fM+8LUIVrAgqcNW2s0PjAxHETgRn9l4fvX31ZxDxvwQnyMOX",
                        (attribute "crossorigin") "anonymous",
                    ]
                    [],
                (element "title") [] [text "Roc + HTMX"],
            ],
            body
                []
                [
                    div
                        [
                            Hx.get "/loaded",
                            Hx.swap "outerHTML",
                            Hx.trigger "load",
                        ]
                        [],
                ],
        ]
