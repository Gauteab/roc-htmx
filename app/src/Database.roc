interface Database exposes [getPackages] imports [
        pg.Pg.Client,
        pg.Pg.Result,
        pg.Pg.Cmd,
        pf.Env,
        pf.Task.{ Task },
    ]

getPackages : Task (List { name : Str, author : Str }) _
getPackages =
    password <- Env.var "POSTGRES_PASSWORD" |> Task.await

    client <- Pg.Client.withConnect {
            host: "localhost",
            port: 5432,
            user: "postgres",
            database: "postgres",
            auth: Password password,
        }

    Pg.Cmd.new "select name, author from roc_packages"
    |> Pg.Cmd.expectN
        (
            Pg.Result.succeed {
                name: <- Pg.Result.str "name" |> Pg.Result.apply,
                author: <- Pg.Result.str "author" |> Pg.Result.apply,
            }
        )
    |> Pg.Client.command client
