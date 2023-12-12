app "htmx-app"
    packages {
        pf: "https://github.com/roc-lang/basic-webserver/releases/download/0.1/dCL3KsovvV-8A5D_W_0X_abynkcRcoAngsgF0xtvQsk.tar.br",
        html: "https://github.com/Hasnep/roc-html/releases/download/v0.2.0/5fqQTpMYIZkigkDa2rfTc92wt-P_lsa76JVXb8Qb3ms.tar.br",
        htmx: "../package/main.roc",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Http.{ Request, Response },
        pf.Url,
        pf.Utc,
        html.Html.{ div, text },
        html.Attribute,
        htmx.Hx,
        Index,
    ]
    provides [main] to pf

hello : Html.Node
hello =
    div [Attribute.id "parent-div"] [
        Html.button
            [
                Hx.post "/clicked",
                Hx.trigger "click",
                Hx.target "#parent-div",
                Hx.swap "outerHTML",
            ]
            [text "Click Me!"],
    ]

htmlResponse : Html.Node -> Task Response []
htmlResponse = \html ->
    htmlText = Html.render html
    Task.ok { status: 200, headers: [], body: Str.toUtf8 htmlText }

main : Request -> Task Response []
main = \req ->

    # Log request date, method and url
    date <- Utc.now |> Task.map Utc.toIso8601Str |> Task.await
    {} <- Stdout.line "\(date) \(Http.methodToStr req.method) \(req.url)" |> Task.await

    when Url.path (Url.fromStr req.url) is
        "/" -> htmlResponse Index.html
        "/loaded" -> htmlResponse hello
        "/clicked" -> htmlResponse (text "Clicked!")
        _ -> Task.ok { status: 404, headers: [], body: [] }
