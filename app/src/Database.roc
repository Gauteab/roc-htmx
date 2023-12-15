interface Database exposes [getPackages, Package] imports [
        pg.Pg.Client,
        pg.Pg.Result,
        pg.Pg.Cmd,
        pf.Env,
        pf.Task.{ Task },
    ]

withClient = \callback ->
    password <- Env.var "POSTGRES_PASSWORD" |> Task.await

    Pg.Client.withConnect
        {
            host: "localhost",
            port: 5432,
            user: "postgres",
            database: "roc_packages",
            auth: Password password,
        }
        callback

Package : { name : Str, author : Str }

getPackages : { name : Str, author : Str } -> Task (List Package) _
getPackages = \search ->
    dbg
        search

    client <- withClient

    decoder =
        Pg.Result.succeed {
            name: <- Pg.Result.str "name" |> Pg.Result.apply,
            author: <- Pg.Result.str "author" |> Pg.Result.apply,
        }

    Pg.Cmd.new "select name, author from packages where name like $1 and author like $2"
    |> Pg.Cmd.bind [Pg.Cmd.str "%\(search.name)%", Pg.Cmd.str "%\(search.author)%"]
    |> Pg.Cmd.expectN decoder
    |> Pg.Client.command client
