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

getPackages : Task (List Package) _
getPackages =
    client <- withClient

    decoder =
        Pg.Result.succeed {
            name: <- Pg.Result.str "name" |> Pg.Result.apply,
            author: <- Pg.Result.str "author" |> Pg.Result.apply,
        }

    Pg.Cmd.new "select name, author from packages"
    |> Pg.Cmd.expectN decoder
    |> Pg.Client.command client
