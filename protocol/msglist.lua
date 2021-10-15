local msg = {
    list = {
        [10000] = "Item.Use",
        [10001] = "Item.Buy",
    } 
}

msg.get_by_key = function (key)
    return msg.list[key]
end

msg.get_by_value = function (value)
    for k,v in pairs(msg.list) do
        if v == value then
            return k
        end
    end
end

return msg