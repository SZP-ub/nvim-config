return {

    {
        "romainl/vim-cool",
        event = "VeryLazy",
    },

    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings({

                function(ch0, ch1, ch2)
                    return not (
                        ch1:match('%s') or
                        ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
                    )
                end,

            })
        end
    }
}
