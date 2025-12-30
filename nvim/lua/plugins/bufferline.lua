return {
    {
        "akinsho/bufferline.nvim",
        lazy = false,
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                -- your custom bufferline options here
                separator_style = "thick",
                always_show_bufferline = true,
                -- etc.
            },
            highlights = {
                -- Optional: override highlight groups if you want full control
            },
        },
    },
}
