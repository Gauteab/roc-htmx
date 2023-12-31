app "htmx-app"
    packages {
        # pf: "https://github.com/roc-lang/basic-webserver/releases/download/0.1/dCL3KsovvV-8A5D_W_0X_abynkcRcoAngsgF0xtvQsk.tar.br",
        pf: "../../basic-webserver/platform/main.roc",
        html: "https://github.com/Hasnep/roc-html/releases/download/v0.2.0/5fqQTpMYIZkigkDa2rfTc92wt-P_lsa76JVXb8Qb3ms.tar.br",
        htmx: "../../package/main.roc",
        pg: "../../roc-pg/src/main.roc",

    }
    imports [
        pg.Pg.Client,
        pg.Pg.Result,
        pg.Pg.Cmd,
        # Unused but required because of: https://github.com/roc-lang/roc/issues/5477
        pf.Tcp,
        pf.Stdout,
        pf.Env,
        pf.Task.{ Task },
        pf.Http.{ Request, Response, header },
        pf.Url.{ Url },
        pf.Utc,
        html.Html,
        html.Attribute,
        htmx.Hx,
        Pages.Index,
        Pages.Hello,
        Pages.Packages,
        Database,
    ]
    provides [main] to pf

htmlResponse = \html ->
    htmlText = Html.renderWithoutDocType html
    Task.ok {
        status: 200,
        headers: [header "Content-type" "text/html"],
        body: Str.toUtf8 htmlText,
    }

parseFormData : Str -> Dict Str Str
parseFormData = \body ->
    body
    |> Str.split "&"
    |> List.keepOks
        (\assignment ->
            parts = Str.split assignment "="
            fst <- List.get parts 0 |> Result.try
            snd <- List.get parts 1 |> Result.try
            Ok (fst, snd)
        )
    |> Dict.fromList

parseFormDataBody : Request -> Dict Str Str
parseFormDataBody = \req ->
    when req.body is
        EmptyBody ->
            Dict.empty {}

        Body body ->
            body.body |> Str.fromUtf8 |> Result.withDefault "" |> parseFormData

getPackageSearch = \req ->
    formData = parseFormDataBody req
    dbg
        formData

    name <- Dict.get formData "name" |> Result.try
    author <- Dict.get formData "author" |> Result.try
    Ok { name, author }

handleRequest : Request -> Task Response _
handleRequest = \req ->

    when urlSegments req.url is
        [] -> htmlResponse Pages.Index.html
        ["loaded"] -> htmlResponse Pages.Hello.html
        ["clicked"] -> htmlResponse (Html.text "Clicked!")
        ["packages"] -> htmlResponse Pages.Packages.html
        ["search"] ->
            when getPackageSearch req is
                Err _ -> Task.err MissingSearchParam
                Ok search ->
                    packages <- Database.getPackages search |> Task.await
                    htmlResponse (Pages.Packages.render packages)

        _ -> Task.err RouteNotFound

main : Request -> Task Response []
main = \req ->

    date <- Utc.now |> Task.map Utc.toIso8601Str |> Task.await
    {} <- Stdout.line "\(date) \(Http.methodToStr req.method) \(req.url)" |> Task.await

    result <- handleRequest req |> Task.attempt
    when result is
        Ok response ->
            Task.ok response

        Err RouteNotFound ->
            Task.ok {
                status: 404,
                headers: [],
                body: "Not found" |> Str.toUtf8,
            }

        Err (BadRequest err) ->
            Task.ok {
                status: 400,
                headers: [],
                body: err |> Str.toUtf8,
            }

        Err (TcpConnectErr _) ->
            dbg
                TcpConneErr

            Task.ok {
                status: 500,
                headers: [],
                body:
                """
                Failed to connect to PostgreSQL Server.

                Make sure it's running on localhost:5432, or tweak the connection params in examples/store/server.roc.
                """
                |> Str.toUtf8,
            }

        Err (TcpPerformErr (PgErr err)) ->
            dbg
                err

            if err.code == "3D000" then
                Task.ok {
                    status: 500,
                    headers: [],
                    body:
                    """
                    It looks like the `roc_pg_example` db hasn't been created.

                    See examples/store/README.md for instructions.
                    """
                    |> Str.toUtf8,
                }
            else
                errStr = Pg.Client.errorToStr err

                Task.ok {
                    status: 500,
                    headers: [],
                    body: errStr |> Str.toUtf8,
                }

        Err e ->
            dbg
                e

            Task.ok {
                status: 500,
                headers: [],
                body: "Something went wrong" |> Str.toUtf8,
            }

# expect (urlSegments "") == []
# expect (urlSegments "/") == []
# expect (urlSegments "/a") == ["a"]
# expect (urlSegments "/a/b") == ["a", "b"]

urlSegments : Str -> List Str
urlSegments = \url ->
    if url == "" || url == "/" then
        []
    else
        url
        |> Url.fromStr
        |> Url.path
        |> Str.split "/"
        |> List.dropFirst 1

