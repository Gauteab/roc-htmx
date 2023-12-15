## # HTMX
##
## This package consist of helper functions for htmx attributes that can be used alongside Hasnep/roc-html
interface Hx
    exposes [
        get,
        post,
        trigger,
        target,
        swap,
        indicator,
    ]
    imports [html.Attribute]

get = Attribute.attribute "hx-get"

post = Attribute.attribute "hx-post"

trigger = Attribute.attribute "hx-trigger"

target = Attribute.attribute "hx-target"

swap = Attribute.attribute "hx-swap"

indicator = Attribute.attribute "hx-indicator"
